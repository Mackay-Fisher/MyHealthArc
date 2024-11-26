import XCTest
import Fluent
import FluentMongoDriver
import Vapor
import MongoKitten
import XCTVapor
@testable import App

final class UserTest: XCTestCase {
    var app: Application!
    var userCollection: MongoKitten.MongoCollection!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
        guard let databaseURL = Environment.get("DATABASE_URL") else {
            XCTFail("DATABASE_URL not set")
            return
        }
        let mongoDB = try await MongoDatabase.connect(databaseURL, on: app.eventLoopGroup.next()).get()
        userCollection = mongoDB["users"]
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testSignup() async throws {
        let userDTO = UserDTO(fullName: "Test User", email: "testuser@example.com", password: "password123")
        try await deleteUser(email: userDTO.email)
        try await signupUser(userDTO: userDTO)
        try await deleteUser(email: userDTO.email)
    }

    func testLogin() async throws {
        let userDTO = UserDTO(fullName: "Test User", email: "testuser@example.com", password: "password123")
        try await deleteUser(email: userDTO.email)
        try await signupUser(userDTO: userDTO)
        try await loginUser(email: userDTO.email, password: userDTO.password)
        try await deleteUser(email: userDTO.email)
    }

    func testGetUserByHash() async throws {
        let userDTO = UserDTO(fullName: "Test User", email: "testuser@example.com", password: "password123")
        try await deleteUser(email: userDTO.email)
        try await signupUser(userDTO: userDTO)
        let userHash = SHA256.hash(data: Data(userDTO.email.utf8)).hexEncodedString()
        try await getUserByHash(userHash: userHash)
        try await deleteUser(email: userDTO.email)
    }

    func testSignupAndLogin() async throws {
        let userDTO = UserDTO(fullName: "Test User", email: "testuser@example.com", password: "password123")
        try await deleteUser(email: userDTO.email)
        try await signupUser(userDTO: userDTO)
        try await loginUser(email: userDTO.email, password: userDTO.password)
        try await deleteUser(email: userDTO.email)
    }

    func testSignupAndGetUserByHash() async throws {
        let userDTO = UserDTO(fullName: "Test User", email: "testuser@example.com", password: "password123")
        try await deleteUser(email: userDTO.email)
        try await signupUser(userDTO: userDTO)
        let userHash = SHA256.hash(data: Data(userDTO.email.utf8)).hexEncodedString()
        try await getUserByHash(userHash: userHash)
        try await deleteUser(email: userDTO.email)
    }

    func testSignupLoginAndGetUserByHash() async throws {
        let userDTO = UserDTO(fullName: "Test User", email: "testuser@example.com", password: "password123")
        try await deleteUser(email: userDTO.email)
        try await signupUser(userDTO: userDTO)
        try await loginUser(email: userDTO.email, password: userDTO.password)
        let userHash = SHA256.hash(data: Data(userDTO.email.utf8)).hexEncodedString()
        try await getUserByHash(userHash: userHash)
        try await deleteUser(email: userDTO.email)
    }

    private func signupUser(userDTO: UserDTO) async throws {
        try await app.test(.POST, "/users/signup", beforeRequest: { req in
            try req.content.encode(userDTO)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok, "Failed to signup user")
        })

        guard let dbItem = try await userCollection.findOne(["email": userDTO.email.lowercased()], as: User.self).get() else {
            XCTFail("Failed to fetch the user document from the database")
            return
        }

        XCTAssertEqual(dbItem.email, userDTO.email.lowercased(), "Email does not match")
        XCTAssertEqual(dbItem.fullName, userDTO.fullName, "Full name does not match")
    }

    private func loginUser(email: String, password: String) async throws {
        let loginDTO = LoginDTO(email: email, password: password)
        try await app.test(.POST, "/users/login", beforeRequest: { req in
            try req.content.encode(loginDTO)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok, "Failed to login user")
        })
    }

    private func getUserByHash(userHash: String) async throws {
        try await app.test(.GET, "/users/\(userHash)", afterResponse: { res in
            XCTAssertEqual(res.status, .ok, "Failed to fetch user by hash")
            let user = try res.content.decode(User.self)
            XCTAssertEqual(user.userHash, userHash, "User hash does not match")
        })
    }

    private func deleteUser(email: String) async throws {
        _ = try await userCollection.deleteOne(where: ["email": email.lowercased()]).get()
    }
}