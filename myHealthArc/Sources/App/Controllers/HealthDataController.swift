import Vapor
import MongoSwift

struct HealthData: Codable {
    let userId: String
    let data: [[String: Any]]
    let timestamp: Date
}

final class HealthDataController {
    let collection: MongoCollection<HealthData>

    init(database: MongoDatabase) {
        self.collection = database.collection("user_health_data", withType: HealthData.self)
    }

    func uploadHealthData(_ req: Request) async throws -> HTTPStatus {
        let healthData = try req.content.decode(HealthData.self)
        try await collection.insertOne(healthData)
        return .created
    }

    func fetchHealthData(_ req: Request) async throws -> [HealthData] {
        let userId = try req.query.get(String.self, at: "userId")
        return try await collection.find(["userId": userId]).toArray()
    }
}
