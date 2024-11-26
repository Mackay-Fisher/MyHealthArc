import XCTest
import Fluent
import FluentMongoDriver
import Vapor
import MongoKitten
import XCTVapor
@testable import App

final class GoalsTest: XCTestCase {
    var app: Application!
    var userGoalsCollection: MongoKitten.MongoCollection!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
        guard let databaseURL = Environment.get("DATABASE_URL") else {
            XCTFail("DATABASE_URL not set")
            return
        }
        let mongoDB = try await MongoDatabase.connect(databaseURL, on: app.eventLoopGroup.next()).get()
        userGoalsCollection = mongoDB["user_goals"]
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testCreateUserGoals() async throws {
        let userId = "testUser1"
        let goals = ["step_count": 10000, "calories_burned": 500]

        try await createUserGoals(userId: userId, goals: goals)

        let fetchedGoals = try await userGoalsCollection.findOne(["userId": userId], as: UserGoals.self).get()
        XCTAssertNotNil(fetchedGoals, "Failed to fetch user goals from the database")
        XCTAssertEqual(fetchedGoals?.goals, goals, "Fetched goals do not match the created goals")

        try await deleteUserGoals(userId: userId)
    }

    private func createUserGoals(userId: String, goals: [String: Int]) async throws {
        let newUserGoals = UserGoals(userId: userId, goals: goals)
        let document = try BSONEncoder().encode(newUserGoals)
        try await userGoalsCollection.insert(document)
    }

    private func deleteUserGoals(userId: String) async throws {
        _ = try await userGoalsCollection.deleteOne(where: ["userId": userId]).get()
    }
}