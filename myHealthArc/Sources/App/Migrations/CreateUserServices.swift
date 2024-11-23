import Fluent

struct CreateUserService: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("user_services")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("selected_services", .json, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("user_services").delete()
    }
}
