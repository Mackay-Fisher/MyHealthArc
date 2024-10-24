import Fluent

struct CreateNutritionItem: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("nutrition_item")
            .id()
            .field("food_item", .string, .required)
            .field("protein", .double, .required)
            .field("carbohydrates", .double, .required)
            .field("fats", .double, .required)
            .field("calories", .int, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("nutrition_item").delete()
    }
}
