import Vapor
import Fluent

final class UserGoals: Model, Content {
    static let schema = "user_goals"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "user_id")
    var userId: String

    @Field(key: "goals")
    var goals: [String: Int]

    init() {}

    init(id: UUID? = nil, userId: String, goals: [String: Int]) {
        self.id = id
        self.userId = userId
        self.goals = goals
    }
}

final class UserStreaks: Model, Content {
    static let schema = "user_streaks"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "user_id")
    var userId: String

    @Field(key: "streaks")
    var streaks: [String: Int]

    @Field(key: "last_updated")
    var lastUpdated: Date

    init() {}

    init(id: UUID? = nil, userId: String, streaks: [String: Int], lastUpdated: Date) {
        self.id = id
        self.userId = userId
        self.streaks = streaks
        self.lastUpdated = lastUpdated
    }
}
