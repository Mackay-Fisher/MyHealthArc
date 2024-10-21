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
    
    init() { }
    
    init(id: UUID? = nil, fullName: String, email: String, passwordHash: String, userHash: String) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.passwordHash = passwordHash
        self.userHash = userHash
    }
}