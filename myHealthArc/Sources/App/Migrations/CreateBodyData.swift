import Fluent

struct CreateBodyData: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("body_data")
            .id()
            .field("userHash", .string, .required)
            .field("height", .double, .required)
            .field("weight", .double, .required)
            .field("age", .int, .required)
            .field("gender", .string, .required)
            .field("bmi", .double)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("body_data").delete()
    }
}
