/*
    Should run InsertUsersTest.swift before running this test to populate the respective collections
*/

import XCTest
import Fluent
import FluentMongoDriver
import Vapor
import MongoKitten
@testable import App

final class CreateMedicationsTest: XCTestCase {
    var app: Application!
    var usersCollection: MongoKitten.MongoCollection!
    var medicationsCollection: MongoKitten.MongoCollection!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
        guard let databaseURL = Environment.get("DATABASE_URL") else {
            XCTFail("DATABASE_URL not set")
            return
        }
        let mongoDB = try await MongoDatabase.connect(databaseURL, on: app.eventLoopGroup.next()).get()
        usersCollection = mongoDB["users"]
        medicationsCollection = mongoDB["medications"]
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testCreateMedicationsForUsers() async throws {
        let users = try await usersCollection.find().decode(User.self).allResults()
        XCTAssertFalse(users.isEmpty, "No users found in the users collection")

        for user in users {
            let randomInt = Int.random(in: 1...100)
            let medication = Medication(
                userHash: user.userHash,
                name: "Test Medication \(randomInt)",
                dosage: "\(randomInt)mg",
                frequency: "Once a week",
                conflicts: []
            )
            try await medicationsCollection.insertEncoded(medication).get()
        }

        let medications = try await medicationsCollection.find().decode(Medication.self).allResults()
        XCTAssertEqual(medications.count, users.count, "The number of inserted medications should match the number of users in the users collection")
    }
}