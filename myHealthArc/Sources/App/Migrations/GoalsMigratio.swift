import Fluent

struct CreateUserGoals: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("user_goals")
            .id()
            .field("user_id", .string, .required)
            .field("goals", .dictionary(of: .int), .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("user_goals").delete()
    }
}

struct CreateUserStreaks: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("user_streaks")
            .id()
            .field("user_id", .string, .required)
            .field("streaks", .dictionary(of: .int), .required)
            .field("last_updated", .date, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("user_streaks").delete()
    }
}
