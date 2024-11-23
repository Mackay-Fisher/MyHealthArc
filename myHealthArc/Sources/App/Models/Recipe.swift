import Fluent
import Vapor

final class Recipe: Model, Content {
    static let schema = "recipes"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "content")
    var content: String

    @Field(key: "userHash")
    var userHash: String

    init() { }

    init(id: UUID? = nil, name: String, content: String, userHash: String) {
        self.id = id
        self.name = name
        self.content = content
        self.userHash = userHash
    }
}