import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("passwordHash", .string, .required)
            // May delete lines 10/11 because possible privacy concerns with storing the name with the nutrition/medication information
            .field("nutrition_info", .array(of: .dictionary), .required)
            .field("medication_info", .array(of: .dictionary), .required)
            .create()
    }

    func revert(on database: Database) async throws {
        //try await database.schema("users").delete()
    }
}