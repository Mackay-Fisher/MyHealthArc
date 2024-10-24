import Fluent

struct CreateMedicationInteractions: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("medication_interactions")
            .id()
            .field("medications", .array(of: .string), .required)
            .field("conflicts", .array(of: .string), .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("medication_interactions").delete()
    }
}
