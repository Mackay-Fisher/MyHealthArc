import Fluent
import Vapor

final class HealthDataModel: Model, Content {
    static let schema = "health_data"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "userHash")
    var userHash: String

    @Field(key: "data")
    var data: [HealthData]

    init() {}

    init(id: UUID? = nil, userHash: String, data: [HealthData]) {
        self.id = id
        self.userHash = userHash
        self.data = data
    }
}

final class FitnessDataModel: Model, Content {
    static let schema = "fitness_data"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "userHash")
    var userHash: String

    @Field(key: "data")
    var data: [FitnessData]

    init() {}

    init(id: UUID? = nil, userHash: String, data: [FitnessData]) {
        self.id = id
        self.userHash = userHash
        self.data = data
    }
}

struct HealthData: Codable {
    let type: String
    let value: Double
    let date: Date
}

struct FitnessData: Codable {
    let type: String
    let value: Double
    let date: Date
}
