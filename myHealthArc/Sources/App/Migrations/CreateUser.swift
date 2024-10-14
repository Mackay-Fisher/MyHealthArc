import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("nutrition_info", .array(of: .dictionary), .required)
            .field("medication_info", .array(of: .dictionary), .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}