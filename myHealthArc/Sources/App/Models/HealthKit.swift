import Fluent
import Vapor

final class HealthKit: Model, Content, @unchecked Sendable {
    static let schema = "healthkit"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "userHash")
    var userHash: String
    
    @Field(key: "steps")
    var steps: Int
    
    @Field(key: "heartRate")
    var heartRate: Int
    
    @Field(key: "hoursSleep")
    var hoursSleep: Double
    
    init() { }
    
    init(id: UUID? = nil, userHash: String, steps: Int, heartRate: Int, hoursSleep: Double) {
        self.id = id
        self.userHash = userHash
        self.steps = steps
        self.heartRate = heartRate
        self.hoursSleep = hoursSleep
    }
}