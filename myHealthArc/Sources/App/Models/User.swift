import Fluent
import Vapor

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "fullName")
    var fullName: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "passwordHash")
    var passwordHash: String
    
    @Field(key: "userHash")
    var userHash: String

    @Field(key: "appleHealthEnabled")
    var appleHealthEnabled: Bool

    @Field(key: "appleFitnessEnabled")
    var appleFitnessEnabled: Bool

    @Field(key: "prescriptionsEnabled")
    var prescriptionsEnabled: Bool

    @Field(key: "nutritionEnabled")
    var nutritionEnabled: Bool

    
    init() { }
    
    init(id: UUID? = nil, fullName: String, email: String, passwordHash: String, userHash: String,
     appleHealthEnabled: Bool = false, appleFitnessEnabled: Bool = false,
     prescriptionsEnabled: Bool = false, nutritionEnabled: Bool = false) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.passwordHash = passwordHash
        self.userHash = userHash
        self.appleHealthEnabled = appleHealthEnabled
        self.appleFitnessEnabled = appleFitnessEnabled
        self.prescriptionsEnabled = prescriptionsEnabled
        self.nutritionEnabled = nutritionEnabled
    }

}