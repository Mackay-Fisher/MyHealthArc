import Fluent
import Vapor
import FluentMongoDriver

@preconcurrency
final class NutritionItem: Model, Content {
    static let schema = "nutrition_items"

    @ID(custom: "_id")
    var id: ObjectId?

    @Field(key: "foodItem")
    var foodItem: String

    @Field(key: "proteinMinimum")
    var proteinMinimum: Double

    @Field(key: "proteinMaximum")
    var proteinMaximum: Double

    @Field(key: "carbohydratesMinimum")
    var carbohydratesMinimum: Double

    @Field(key: "carbohydratesMaximum")
    var carbohydratesMaximum: Double

    @Field(key: "fatsMinimum")
    var fatsMinimum: Double

    @Field(key: "fatsMaximum")
    var fatsMaximum: Double

    @Field(key: "caloriesMinimum")
    var caloriesMinimum: Int

    @Field(key: "caloriesMaximum")
    var caloriesMaximum: Int

    init() {}

    init(foodItem: String, proteinMinimum: Double, proteinMaximum: Double, carbohydratesMinimum: Double, carbohydratesMaximum: Double, fatsMinimum: Double, fatsMaximum: Double, caloriesMinimum: Int, caloriesMaximum: Int) {
        self.foodItem = foodItem
        self.proteinMinimum = proteinMinimum
        self.proteinMaximum = proteinMaximum
        self.carbohydratesMinimum = carbohydratesMinimum
        self.carbohydratesMaximum = carbohydratesMaximum
        self.fatsMinimum = fatsMinimum
        self.fatsMaximum = fatsMaximum
        self.caloriesMinimum = caloriesMinimum
        self.caloriesMaximum = caloriesMaximum
    }
}
