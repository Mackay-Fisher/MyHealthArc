import Fluent

struct CreateUserService: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("user_services")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("selected_services", .json, .required)
            .field("is_face_id_enabled", .bool, .required, .custom("DEFAULT FALSE"))
            .unique(on: "user_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("user_services").delete()
    }
}
