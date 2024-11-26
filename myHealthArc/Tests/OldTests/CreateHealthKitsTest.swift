/*
    Should run InsertUsersTest.swift before running this test to populate the respective collections
*/

import XCTest
import Fluent
import FluentMongoDriver
import Vapor
import MongoKitten
@testable import App

final class CreateHealthKitsTest: XCTestCase {
    var app: Application!
    var usersCollection: MongoKitten.MongoCollection!
    var healthKitCollection: MongoKitten.MongoCollection!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
        guard let databaseURL = Environment.get("DATABASE_URL") else {
            XCTFail("DATABASE_URL not set")
            return
        }
        let mongoDB = try await MongoDatabase.connect(databaseURL, on: app.eventLoopGroup.next()).get()
        usersCollection = mongoDB["users"]
        healthKitCollection = mongoDB["healthkit"]
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testCreateHealthKitsForUsers() async throws {
        let users = try await usersCollection.find().decode(User.self).allResults()
        XCTAssertFalse(users.isEmpty, "No users found in the users collection")

        for user in users {
            let randomInt = Int.random(in: 1...100)
            let healthKit = HealthKit(
                userHash: user.userHash,
                steps: randomInt * 100,
                heartRate: 60,
                hoursSleep: 8
            )
            try await healthKitCollection.insertEncoded(healthKit).get()
        }

        let healthKits = try await healthKitCollection.find().decode(HealthKit.self).allResults()
        XCTAssertEqual(healthKits.count, users.count, "The number of inserted healthkit documents should match the number of users in the users collection")
    }
}