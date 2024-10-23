import XCTest
import Fluent
import FluentMongoDriver
import Vapor
import MongoKitten
@testable import App

final class SchemaTests: XCTestCase {
    var app: Application!
    var mongoDB: MongoDatabase!

    // The setUp() function sets up the test environment before each test and connects to the MongoDB database.
    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
        guard let databaseURL = Environment.get("DATABASE_URL") else {
            XCTFail("DATABASE_URL not set")
            return
        }
        mongoDB = try await MongoDatabase.connect(databaseURL, on: app.eventLoopGroup.next()).get()
    }

    // The tearDown() function clean up resources and shut down app.
    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    // Test function to verify that the user schema is migrated to the users collection and that the users collection exists in the database. Reverts migration after the test is complete.
    func testUserSchema() throws {
        let expectation = self.expectation(description: "Test users migration")
        try app.autoMigrate().wait()

        let collectionsFuture = mongoDB.listCollections()
        collectionsFuture.whenComplete { result in
            switch result {
            case .success(let collections):
                let collectionNames = collections.map { $0.name }
                XCTAssertNotNil(collectionNames)
                XCTAssertTrue(collectionNames.contains("users"), "users collection doesn't exist or isn't found. Collections: \(collectionNames)")

                for collection in collectionNames {
                    print("Collection: \(collection)")
                }
            case .failure(let error):
                XCTFail("Failed to list collections: \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
        try app.autoRevert().wait()
    }
}