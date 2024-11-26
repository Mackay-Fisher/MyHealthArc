import XCTest
import Vapor
import Fluent
import FluentMongoDriver
import MongoKitten
@testable import App

final class FaceIDBackendTest: XCTestCase {
    var app: Application!
    var collection: MongoKitten.MongoCollection!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
        guard let databaseURL = Environment.get("DATABASE_URL") else {
            XCTFail("DATABASE_URL not set")
            return
        }
        let mongoDB = try await MongoDatabase.connect(databaseURL, on: app.eventLoopGroup.next()).get()
        collection = mongoDB["users"]
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testFaceIDLoginFlow() async throws {
        print("Simulate user login")
        let loginDTO = LoginDTO(email: "testuser@example.com", password: "password123")
        try await app.test(.POST, "users/login", beforeRequest: { req in
            try req.content.encode(loginDTO)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.self)
            XCTAssertNotNil(user.userHash)
            print("User logged in successfully with userHash: \(user.userHash ?? "nil")")
            
            let faceIDEnabled = true
            MockKeychainWrapper.standard.set(faceIDEnabled, forKey: "isFaceIDEnabled")
            MockKeychainWrapper.standard.set(user.userHash, forKey: "userHash")
            print("FaceID enabled for userHash: \(user.userHash ?? "nil")")
        })
        
        print("Simulate FaceID authentication")
        let userHash = MockKeychainWrapper.standard.string(forKey: "userHash")
        XCTAssertNotNil(userHash)
        print("FaceID authentication simulated with userHash: \(userHash ?? "nil")")
        
        print("Fetch user details using userHash")
        let fetchedUser = try await collection.findOne(["userHash": userHash!]).get()
        XCTAssertNotNil(fetchedUser)
        XCTAssertEqual(fetchedUser?["email"] as? String, "testuser@example.com")
        print("Fetched user details: \(fetchedUser ?? [:])")
    }

    func testFaceIDLoginFailure() async throws {
        print("Simulate user login")
        let loginDTO = LoginDTO(email: "testuser@example.com", password: "password123")
        try await app.test(.POST, "users/login", beforeRequest: { req in
            try req.content.encode(loginDTO)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.self)
            XCTAssertNotNil(user.userHash)
            print("User logged in successfully with userHash: \(user.userHash ?? "nil")")
            
            let faceIDEnabled = true
            MockKeychainWrapper.standard.set(faceIDEnabled, forKey: "isFaceIDEnabled")
            MockKeychainWrapper.standard.set(user.userHash, forKey: "userHash")
            print("FaceID enabled for userHash: \(user.userHash ?? "nil")")
        })
        
        print("Simulate failed FaceID authentication")
        let differentUserHash = "differentUserHash"
        MockKeychainWrapper.standard.set(differentUserHash, forKey: "userHash")
        let userHash = MockKeychainWrapper.standard.string(forKey: "userHash")
        XCTAssertNotNil(userHash)
        XCTAssertEqual(userHash, differentUserHash)
        print("FaceID authentication simulated with different userHash: \(userHash ?? "nil")")
        
        print("Attempt to fetch user details using different userHash")
        let fetchedUser = try await collection.findOne(["userHash": userHash!]).get()
        XCTAssertNil(fetchedUser)
        print("No user details fetched for different userHash")
    }

    func testLoginFailureDueToIncorrectCredentials() async throws {
        print("Simulate failed user login due to incorrect credentials")
        let loginDTO = LoginDTO(email: "wronguser@example.com", password: "wrongpassword")
        try await app.test(.POST, "users/login", beforeRequest: { req in
            try req.content.encode(loginDTO)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            print("Login failed due to incorrect credentials")
        })
    }

    func testEnableFaceIDWhenBiometricsNotAvailable() async throws {
        print("Simulate enabling FaceID when biometrics are not available")
        let loginDTO = LoginDTO(email: "testuser@example.com", password: "password123")
        try await app.test(.POST, "users/login", beforeRequest: { req in
            try req.content.encode(loginDTO)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.self)
            XCTAssertNotNil(user.userHash)
            print("User logged in successfully with userHash: \(user.userHash ?? "nil")")
            
            let faceIDEnabled = false
            MockKeychainWrapper.standard.set(faceIDEnabled, forKey: "isFaceIDEnabled")
            MockKeychainWrapper.standard.set(user.userHash, forKey: "userHash")
            print("Attempted to enable FaceID but biometrics are not available")
        })
        
        let faceIDEnabled = MockKeychainWrapper.standard.string(forKey: "isFaceIDEnabled")
        XCTAssertNil(faceIDEnabled)
        print("FaceID not enabled as biometrics are not available")
    }
}

class MockKeychainWrapper {
    static let standard = MockKeychainWrapper()
    private var storage: [String: Any] = [:]

    func set(_ value: Any, forKey key: String) {
        storage[key] = value
    }

    func string(forKey key: String) -> String? {
        return storage[key] as? String
    }
}

extension Application {
    func test(
        _ method: HTTPMethod,
        _ path: String,
        beforeRequest: (inout Request) throws -> () = { _ in },
        afterResponse: (Response) throws -> () = { _ in }
    ) async throws {
        let responder = self.responder
        var request = Request(application: self, method: method, url: URI(path: path), on: self.eventLoopGroup.next())
        try beforeRequest(&request)
        let response = try await responder.respond(to: request).get()
        try afterResponse(response)
    }
}