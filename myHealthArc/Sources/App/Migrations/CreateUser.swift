import Fluent
import FluentMongoDriver

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .id()
            .field("email", .string, .required)
            .field("passwordHash", .string, .required)
            .field("fullName", .string, .required)
            .unique(on: "email") // Ensure unique email addresses
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema).delete()
    }
}
