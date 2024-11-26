/*
    Should run InsertUsersTest.swift before running this test to populate the respective collections
*/

import XCTest
import Fluent
import FluentMongoDriver
import Vapor
import MongoKitten
@testable import App

final class CreateNutritionsTest: XCTestCase {
    var app: Application!
    var usersCollection: MongoKitten.MongoCollection!
    var nutritionCollection: MongoKitten.MongoCollection!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
        guard let databaseURL = Environment.get("DATABASE_URL") else {
            XCTFail("DATABASE_URL not set")
            return
        }
        let mongoDB = try await MongoDatabase.connect(databaseURL, on: app.eventLoopGroup.next()).get()
        usersCollection = mongoDB["users"]
        nutritionCollection = mongoDB["nutrition"]
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testCreateNutritionsForUsers() async throws {
        let users = try await usersCollection.find().decode(User.self).allResults()
        XCTAssertFalse(users.isEmpty, "No users found in the users collection")

        for user in users {
            let randomInt = Int.random(in: 1...100)
            let nutrition = Nutrition(
                userHash: user.userHash,
                calories: randomInt * 10,
                protein: Double(randomInt) * 5.0,
                carbohydrates: Double(randomInt) * 0.2,
                fats: Double(randomInt) * 0.5
            )
            try await nutritionCollection.insertEncoded(nutrition).get()
        }

        let nutritions = try await nutritionCollection.find().decode(Nutrition.self).allResults()
        XCTAssertEqual(nutritions.count, users.count, "The number of inserted nutrition documents should match the number of users in the users collection")
    }
}