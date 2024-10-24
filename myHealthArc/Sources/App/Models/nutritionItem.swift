import Fluent
import Vapor
import FluentMongoDriver

final class NutritionItem: Model, Content {
    static let schema = "nutrition_item"

    @ID(custom: "_id")
    var id: ObjectId?

    @Field(key: "food_item")
    var foodItem: String

    @Field(key: "protein")
    var protein: Double

    @Field(key: "carbohydrates")
    var carbohydrates: Double

    @Field(key: "fats")
    var fats: Double

    @Field(key: "calories")
    var calories: Int

    init() { }

    init(id: ObjectId? = nil, foodItem: String, protein: Double, carbohydrates: Double, fats: Double, calories: Int) {
        self.id = id
        self.foodItem = foodItem
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fats = fats
        self.calories = calories
    }
}
