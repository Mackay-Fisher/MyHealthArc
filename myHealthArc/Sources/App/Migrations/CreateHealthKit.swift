import Fluent

struct CreateHealthKit: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("healthkit")
            .id()
            .field("userHash", .string, .required)
            .field("steps", .int, .required)
            .field("heartRate", .int, .required)
            .field("hoursSleep", .double, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("healthkit").delete()
    }
}