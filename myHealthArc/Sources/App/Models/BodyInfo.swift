import Fluent
import Vapor

final class BodyDataModel: Model, Content {
    static let schema = "body_data"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "userHash")
    var userHash: String

    @Field(key: "height")
    var height: Double

    @Field(key: "weight")
    var weight: Double

    @Field(key: "age")
    var age: Int

    @Field(key: "gender")
    var gender: String

    @Field(key: "bmi")
    var bmi: Double?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(userHash: String, height: Double, weight: Double, age: Int, gender: String, bmi: Double?) {
        self.userHash = userHash
        self.height = height
        self.weight = weight
        self.age = age
        self.gender = gender
        self.bmi = bmi
    }
}
