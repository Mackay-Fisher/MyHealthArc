import Vapor
import Fluent

struct GoalsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let goals = routes.grouped("goals")
        goals.get("fetch", use: getUserGoals)
        goals.post("update", use: updateUserGoals)
        goals.post("streaks", use: updateUserStreaks)
        goals.get("streaks", use: fetchUserStreaks)
    }

    // MARK: - Get User Goals
    func getUserGoals(req: Request) async throws -> [String: Int] {
        guard let userId = try? req.query.get(String.self, at: "userId") else {
            throw Abort(.badRequest, reason: "'userId' must be a string.")
        }

        guard let userGoals = try await UserGoals.query(on: req.db)
            .filter(\.$userId == userId)
            .first() else {
            throw Abort(.notFound, reason: "User goals not found.")
        }

        return userGoals.goals
    }

    // MARK: - Update User Goals
    // MARK: - Update User Goals
func updateUserGoals(req: Request) async throws -> HTTPStatus {
    let updatedGoals = try req.content.decode(UserGoals.self)

    // Fetch or create user goals
    if let existingGoals = try await UserGoals.query(on: req.db)
        .filter(\.$userId == updatedGoals.userId)
        .first() {
        existingGoals.goals = updatedGoals.goals
        try await existingGoals.save(on: req.db)
    } else {
        try await updatedGoals.create(on: req.db)
    }

    // Fetch or create user streaks
    var userStreaks = try await UserStreaks.query(on: req.db)
        .filter(\.$userId == updatedGoals.userId)
        .first() ?? UserStreaks(userId: updatedGoals.userId, streaks: [:], lastUpdated: Date())

    // Group goals (e.g., handle nutrition goals)
    let groupedGoals = groupGoals(updatedGoals.goals)

    // Add streaks for new goals or remove streaks for zero-value goals
    for goal in groupedGoals.keys {
        if let goalValue = groupedGoals[goal], goalValue > 0 {
            // Add streak for valid non-zero goal
            if userStreaks.streaks[goal] == nil {
                userStreaks.streaks[goal] = 0 // Initialize streak if it doesn't exist
            }
        } else {
            // Remove streak if the goal is zero
            userStreaks.streaks.removeValue(forKey: goal)
        }
    }

    // Save the updated streaks
    try await userStreaks.save(on: req.db)

    return .ok
}



    // MARK: - Update User Streaks
    // MARK: - Update User Goals
func updateUserStreaks(req: Request) async throws -> [String: Int] {
    let updateData = try req.content.decode([String: Int].self)

    guard let userId = updateData["userId"] as? String else {
        throw Abort(.badRequest, reason: "'userId' must be a string.")
    }

    guard let userGoals = try await UserGoals.query(on: req.db)
        .filter(\.$userId == userId)
        .first() else {
        throw Abort(.notFound, reason: "User goals not found.")
    }

    var userStreaks = try await UserStreaks.query(on: req.db)
        .filter(\.$userId == userId)
        .first() ?? UserStreaks(userId: userId, streaks: [:], lastUpdated: Date())

    // Consolidate goals into groups
    let groupedGoals = groupGoals(userGoals.goals)

    // Check if nutrition-related goals are non-zero
    let nutritionKeys = ["fat-goal", "protein-goal", "carbs-goal", "calories-consumed"]
    let hasNutritionGoals = nutritionKeys.contains { key in
        userGoals.goals[key] ?? 0 > 0
    }

    if hasNutritionGoals {
        // Add a `nutrition` streak if it doesn't already exist
        if userStreaks.streaks["nutrition"] == nil {
            userStreaks.streaks["nutrition"] = 0
        }
    } else {
        // Remove `nutrition` streak if all nutrition goals are zero
        userStreaks.streaks.removeValue(forKey: "nutrition")
    }

    // Update streaks based on grouped goals
    for (key, value) in updateData where key != "userId" {
        if let goalValue = groupedGoals[key], value >= goalValue {
            userStreaks.streaks[key, default: 0] += 1
        } else {
            userStreaks.streaks[key] = 0
        }
    }

    userStreaks.lastUpdated = Date()
    try await userStreaks.save(on: req.db)

    // Return streaks only for grouped goals
    return groupedGoals.keys.reduce(into: [String: Int]()) { result, key in
        if let streakValue = userStreaks.streaks[key] {
            result[key] = streakValue
        }
    }
}




// Group goals into hyphen-separated format
private func groupGoals(_ goals: [String: Int]) -> [String: Int] {
    var groupedGoals: [String: Int] = [:]

    // Grouping nutrition-related goals
    let nutritionKeys = ["fat-goal", "protein-goal", "carbs-goal", "calories-consumed"]
    let nutritionValues = nutritionKeys.compactMap { goals[$0] } // Get all non-nil values

    if !nutritionValues.isEmpty, nutritionValues.contains(where: { $0 > 0 }) {
        groupedGoals["nutrition"] = nutritionValues.reduce(0, +)
    }

    // Add other goals (excluding the nutrition keys)
    for (key, value) in goals where !nutritionKeys.contains(key) {
        if value > 0 { // Only add goals with non-zero values
            groupedGoals[key] = value
        }
    }

    return groupedGoals
}








    // MARK: - Fetch User Streaks
    // MARK: - Fetch User Streaks
func fetchUserStreaks(req: Request) async throws -> [String: Int] {
    guard let userId = try? req.query.get(String.self, at: "userId") else {
        throw Abort(.badRequest, reason: "'userId' must be a string.")
    }

    guard let userGoals = try await UserGoals.query(on: req.db)
        .filter(\.$userId == userId)
        .first() else {
        throw Abort(.notFound, reason: "User goals not found.")
    }

    guard let userStreaks = try await UserStreaks.query(on: req.db)
        .filter(\.$userId == userId)
        .first() else {
        return [:] // No streaks found
    }

    // Consolidate goals into groups
    let groupedGoals = groupGoals(userGoals.goals)

    // Return streaks for grouped goals
    return groupedGoals.keys.reduce(into: [String: Int]()) { result, key in
        if let streakValue = userStreaks.streaks[key] {
            result[key] = streakValue
        }
    }
}


}
