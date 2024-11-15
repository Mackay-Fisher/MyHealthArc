import Fluent
import Vapor

final class Nutrition: Model, Content, @unchecked Sendable {
    static let schema = "nutrition"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "userHash")
    var userHash: String
    
    @Field(key: "foodName")
    var foodName: String
    
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
    
    @OptionalField(key: "modifiedProtein")
    var modifiedProtein: Double?
    
    @OptionalField(key: "modifiedCarbohydrates")
    var modifiedCarbohydrates: Double?
    
    @OptionalField(key: "modifiedFats")
    var modifiedFats: Double?
    
    @OptionalField(key: "modifiedCalories")
    var modifiedCalories: Int?
    
    @Timestamp(key: "time", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, userHash: String, foodName: String, proteinMinimum: Double, proteinMaximum: Double, carbohydratesMinimum: Double, carbohydratesMaximum: Double, fatsMinimum: Double, fatsMaximum: Double, caloriesMinimum: Int, caloriesMaximum: Int, modifiedProtein: Double? = nil, modifiedCarbohydrates: Double? = nil, modifiedFats: Double? = nil, modifiedCalories: Int? = nil) {
        self.id = id
        self.userHash = userHash
        self.foodName = foodName
        self.proteinMinimum = proteinMinimum
        self.proteinMaximum = proteinMaximum
        self.carbohydratesMinimum = carbohydratesMinimum
        self.carbohydratesMaximum = carbohydratesMaximum
        self.fatsMinimum = fatsMinimum
        self.fatsMaximum = fatsMaximum
        self.caloriesMinimum = caloriesMinimum
        self.caloriesMaximum = caloriesMaximum
        self.modifiedProtein = modifiedProtein
        self.modifiedCarbohydrates = modifiedCarbohydrates
        self.modifiedFats = modifiedFats
        self.modifiedCalories = modifiedCalories
    }
}