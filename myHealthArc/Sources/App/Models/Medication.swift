import Fluent
import Vapor

final class Medication: Model, Content {
    static let schema = "medications"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "userHash")
    var userHash: String

    // Array of dictionaries to store medication details
    @Field(key: "medications")
    var medications: [[String: String]] // Each dictionary contains name, dosage, frequency

    @Field(key: "interactions")
    var interactions: [String: [String]] // Interactions stored by medication name

    init() { }

    init(id: UUID? = nil, userHash: String, medications: [[String: String]], interactions: [String: [String]]) {
        self.id = id
        self.userHash = userHash
        self.medications = medications
        self.interactions = interactions
    }
}
