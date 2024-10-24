import Fluent
import Vapor

final class Nutrition: Model, Content, @unchecked Sendable {
    static let schema = "nutrition"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "userHash")
    var userHash: String
    
    @Field(key: "calories")
    var calories: Int
    
    @Field(key: "protein")
    var protein: Double
    
    @Field(key: "carbohydrates")
    var carbohydrates: Double
    
    @Field(key: "fats")
    var fats: Double
    
    init() { }
    
    init(id: UUID? = nil, userHash: String, calories: Int, protein: Double, carbohydrates: Double, fats: Double) {
        self.id = id
        self.userHash = userHash
        self.calories = calories
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fats = fats
    }
}