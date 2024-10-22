import Fluent

struct CreateNutrition: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("nutrition")
            .id()
            .field("userHash", .string, .required)
            .field("calories", .int, .required)
            .field("protein", .double, .required)
            .field("carbohydrates", .double, .required)
            .field("fats", .double, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("nutrition").delete()
    }
}