import Vapor
import MongoSwift

struct FitnessData: Codable {
    let userId: String
    let data: [[String: Any]]
    let timestamp: Date
}

final class FitnessDataController {
    let collection: MongoCollection<FitnessData>

    init(database: MongoDatabase) {
        self.collection = database.collection("user_fitness_data", withType: FitnessData.self)
    }

    func uploadFitnessData(_ req: Request) async throws -> HTTPStatus {
        let fitnessData = try req.content.decode(FitnessData.self)
        try await collection.insertOne(fitnessData)
        return .created
    }

    func fetchFitnessData(_ req: Request) async throws -> [FitnessData] {
        let userId = try req.query.get(String.self, at: "userId")
        return try await collection.find(["userId": userId]).toArray()
    }
}
