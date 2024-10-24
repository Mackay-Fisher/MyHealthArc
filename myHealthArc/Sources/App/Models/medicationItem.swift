import Fluent
import Vapor
import FluentMongoDriver

final class MedicationInteraction: Model, Content {
    static let schema = "medication_interactions"

    @ID(custom: "_id")
    var id: ObjectId?

    @Field(key: "medications")
    var medications: [String]

    @Field(key: "conflicts")
    var conflicts: [String]

    init() { }

    init(id: ObjectId? = nil, medications: [String], conflicts: [String]) {
        self.id = id
        self.medications = medications
        self.conflicts = conflicts
    }
}
