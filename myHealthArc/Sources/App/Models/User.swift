import Vapor
import Fluent
import FluentMongoDriver

final class User: Model, Content {
    static let schema = "users" // MongoDB collection name

    @ID(custom: .id)
    var id: ObjectId?

    @Field(key: "email")
    var email: String

    @Field(key: "passwordHash")
    var passwordHash: String

    @Field(key: "fullName")
    var fullName: String

    init() {}

    init(id: ObjectId? = nil, email: String, passwordHash: String, fullName: String) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
        self.fullName = fullName
    }
}
