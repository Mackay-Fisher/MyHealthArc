import XCTest
import Fluent
import FluentMongoDriver
import Vapor
import MongoKitten
import Crypto
@testable import App

final class InsertUsersTest: XCTestCase {
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

    func generateRandomUser() -> User {
        let randomInt = Int.random(in: 1...100)
        let fullName = "TestUser \(randomInt)"
        let email = "testuser\(randomInt)@example.com"
        let password = "password\(randomInt)"
        let passwordHash = try! Bcrypt.hash(password)
        let userHash = SHA256.hash(data: Data(email.utf8)).hexEncodedString()
        
        return User(
            fullName: fullName,
            email: email,
            passwordHash: passwordHash,
            userHash: userHash
        )
    }

    func testInsertRandomUsers() async throws {
    var users: [User] = []
    for _ in 0..<5 {
        users.append(generateRandomUser())
    }
    
    for user in users {
        try await collection.insertEncoded(user).get()
    }
    
    let fetchedUsers = try await collection.find().decode(User.self).allResults()
    XCTAssertEqual(fetchedUsers.count, 10)
}
}