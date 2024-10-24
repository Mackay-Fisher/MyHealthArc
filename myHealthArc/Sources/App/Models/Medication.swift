import Fluent
import Vapor
import FluentMongoDriver

final class Medication: Model, Content {
    static let schema = "medications"

    @ID(custom: "_id")
    var id: ObjectId?

    @Field(key: "userHash")
    var userHash: String

    @Field(key: "medications")
    var medications: [String]

    @Field(key: "dosages")
    var dosages: [String]

    @Field(key: "frequencies")
    var frequencies: [Int] // Changed to array of integers

    init() { }

    init(id: ObjectId? = nil, userHash: String, medications: [String], dosages: [String], frequencies: [Int]) {
        self.id = id
        self.userHash = userHash
        self.medications = medications
        self.dosages = dosages
        self.frequencies = frequencies
    }
}
