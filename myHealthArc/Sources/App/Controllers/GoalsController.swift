import Vapor
import Fluent

struct GoalsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let goals = routes.grouped("goals")
        goals.get("fetch", use: getUserGoals)
        goals.post("update", use: updateUserGoals)
        goals.post("streaks", use: updateUserStreaks)
    }

    // MARK: - Get User Goals
    func getUserGoals(req: Request) async throws -> [String: Int] {
        // Ensure the userId is passed as a String
        guard let userId = try? req.query.get(String.self, at: "userId") else {
            throw Abort(.badRequest, reason: "'userId' must be a string.")
        }

        // Fetch user goals from the database
        guard let userGoals = try await UserGoals.query(on: req.db)
            .filter(\.$userId == userId)
            .first() else {
            throw Abort(.notFound, reason: "User goals not found.")
        }

        return userGoals.goals
    }

    // MARK: - Update User Goals
    func updateUserGoals(req: Request) async throws -> HTTPStatus {
        let updatedGoals = try req.content.decode(UserGoals.self)

        // Check if goals for the user already exist
        if let existingGoals = try await UserGoals.query(on: req.db)
            .filter(\.$userId == updatedGoals.userId)
            .first() {
            existingGoals.goals = updatedGoals.goals
            try await existingGoals.save(on: req.db)
        } else {
            try await updatedGoals.create(on: req.db)
        }

        return .ok
    }

    // MARK: - Update User Streaks
    func updateUserStreaks(req: Request) async throws -> [String: Int] {
        let updateData = try req.content.decode([String: Int].self)

        // Ensure the userId is passed correctly
        guard let userId = updateData["userId"] as? String else {
            throw Abort(.badRequest, reason: "'userId' must be a string.")
        }

        // Fetch user goals
        guard let userGoals = try await UserGoals.query(on: req.db)
            .filter(\.$userId == userId)
            .first() else {
            throw Abort(.notFound, reason: "User goals not found.")
        }

        // Fetch or create user streaks
        var userStreaks = try await UserStreaks.query(on: req.db)
            .filter(\.$userId == userId)
            .first() ?? UserStreaks(userId: userId, streaks: [:], lastUpdated: Date())

        // Update streaks based on goals
        for (key, value) in updateData where key != "userId" {
            if let goalValue = userGoals.goals[key], value >= goalValue {
                userStreaks.streaks[key, default: 0] += 1
            } else {
                userStreaks.streaks[key] = 0
            }
        }

        userStreaks.lastUpdated = Date()
        try await userStreaks.save(on: req.db)

        return userStreaks.streaks
    }
}
