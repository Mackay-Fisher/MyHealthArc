import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("fullName", .string, .required)
            .unique(on: "email")
            .field("passwordHash", .string, .required)
            .field("userHash", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        //try await database.schema("users").delete()
    }
}