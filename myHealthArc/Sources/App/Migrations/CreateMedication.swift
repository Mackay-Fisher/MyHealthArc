import Fluent

struct CreateMedication: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("medications")
            .id()
            .field("userHash", .string, .required)
            .field("name", .string, .required)
            .field("dosage", .string, .required)
            .field("frequency", .string, .required)
            .field("conflicts", .array(of: .string), .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("medications").delete()
    }
}