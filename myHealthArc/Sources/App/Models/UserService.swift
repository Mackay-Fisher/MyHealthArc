import Fluent
import Vapor

final class UserService: Model, Content {
    static let schema = "user_services"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "apple_health_enabled")
    var appleHealthEnabled: Bool
    
    @Field(key: "apple_fitness_enabled")
    var appleFitnessEnabled: Bool
    
    @Field(key: "prescriptions_enabled")
    var prescriptionsEnabled: Bool
    
    @Field(key: "nutrition_enabled")
    var nutritionEnabled: Bool
    
    init() { }
    
    init(id: UUID? = nil, userID: UUID, appleHealthEnabled: Bool, appleFitnessEnabled: Bool, prescriptionsEnabled: Bool, nutritionEnabled: Bool) {
        self.id = id
        self.$user.id = userID
        self.appleHealthEnabled = appleHealthEnabled
        self.appleFitnessEnabled = appleFitnessEnabled
        self.prescriptionsEnabled = prescriptionsEnabled
        self.nutritionEnabled = nutritionEnabled
    }
}
