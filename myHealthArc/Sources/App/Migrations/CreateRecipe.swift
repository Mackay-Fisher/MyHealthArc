import Fluent

struct CreateRecipe: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("recipes")
            .id()
            .field("name", .string, .required)
            .field("content", .string, .required)
            .field("userHash", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("recipes").delete()
    }
}