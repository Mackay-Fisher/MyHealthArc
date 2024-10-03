import XCTest
import Fluent
import FluentMongoDriver
import Vapor
import MongoKitten
@testable import App

final class MongoTest: XCTestCase {
    var app: Application!
    var collection: MongoKitten.MongoCollection!

    // The setUp() function sets up the test environment before each test and connects to the MongoDB database.
    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
        guard let databaseURL = Environment.get("DATABASE_URL") else {
            XCTFail("DATABASE_URL not set")
            return
        }
        let mongoDB = try await MongoDatabase.connect(databaseURL, on: app.eventLoopGroup.next()).get()
        collection = mongoDB["test"]
    }

    // The tearDown() function clean up resources and shut down app.
    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    // The testInsertUser() function inserts a user into the MongoDB database and then fetches the user to verify that the user was inserted successfully.
    func testInsertUser() throws {
        let expectation = self.expectation(description: "Insert and fetch the test user")

        struct User: Codable {
            var _id: ObjectId?
            var name: String
            var email: String
        }

        let user = User(name: "Test User", email: "testuser@example.com")
        let insertFuture = collection.insertEncoded(user)

        insertFuture.whenComplete { result in
            switch result {
            case .success:
                let findFuture = self.collection.findOne(["name": user.name])
                findFuture.whenComplete { findResult in
                    switch findResult {
                    case .success(let fetchedUser):
                        XCTAssertNotNil(fetchedUser)
                        XCTAssertEqual(fetchedUser?["name"] as? String, user.name)
                        XCTAssertEqual(fetchedUser?["email"] as? String, user.email)
                    case .failure(_):
                        XCTFail("Failed to fetch user")
                    }
                    expectation.fulfill()
                }
            case .failure(_):
                XCTFail("Failed to insert user")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
}