import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "passwordHash")
    var passwordHash: String
    
    @Field(key: "userHash")
    var userHash: String
    
    init() { }
    
    init(id: UUID? = nil, name: String, email: String, passwordHash: String, userHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.userHash = userHash
    }
}