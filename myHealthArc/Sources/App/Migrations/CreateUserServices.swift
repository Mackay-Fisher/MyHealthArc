import Fluent

struct CreateUserService: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("user_services")
            .id()
            .field("user_hash", .string, .required)
            .field("selected_services", .dictionary(of: .bool), .required)
            .field("is_face_id_enabled", .bool, .required, .custom("DEFAULT FALSE"))
            .unique(on: "user_hash") // Enforce uniqueness
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("user_services").delete()
    }
}



