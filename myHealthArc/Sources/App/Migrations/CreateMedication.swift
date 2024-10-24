import Fluent

struct CreateMedication: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("medications")
            .id()
            .field("userHash", .string, .required)
            .field("medications", .array(of: .string), .required)
            .field("dosages", .array(of: .string), .required)
            .field("frequencies", .array(of: .int), .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("medications").delete()
    }
}
