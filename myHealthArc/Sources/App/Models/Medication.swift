import Fluent
import Vapor

final class Medication: Model, Content, @unchecked Sendable {
    static let schema = "medications"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "userHash")
    var userHash: String
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "dosage")
    var dosage: String
    
    @Field(key: "frequency")
    var frequency: String
    
    @Field(key: "conflicts")
    var conflicts: [String]
    
    init() { }
    
    init(id: UUID? = nil, userHash: String, name: String, dosage: String, frequency: String, conflicts: [String] = []) {
        self.id = id
        self.userHash = userHash
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.conflicts = conflicts
    }
}