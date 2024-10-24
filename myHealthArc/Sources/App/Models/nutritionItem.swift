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

    @Field(key: "protein")
    var protein: Double

    @Field(key: "carbohydrates")
    var carbohydrates: Double

    @Field(key: "fats")
    var fats: Double

    @Field(key: "calories")
    var calories: Int

    init() {}

    init(foodItem: String, protein: Double, carbohydrates: Double, fats: Double, calories: Int) {
        self.foodItem = foodItem
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fats = fats
        self.calories = calories
    }
}
