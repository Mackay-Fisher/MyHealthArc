import Vapor

final class HealthKitController {
    let healthDataController: HealthDataController
    let fitnessDataController: FitnessDataController

    init(database: MongoDatabase) {
        self.healthDataController = HealthDataController(database: database)
        self.fitnessDataController = FitnessDataController(database: database)
    }

    func uploadData(_ req: Request) async throws -> HTTPStatus {
        if let healthData = try? req.content.decode(HealthData.self) {
            return try await healthDataController.uploadHealthData(req)
        } else if let fitnessData = try? req.content.decode(FitnessData.self) {
            return try await fitnessDataController.uploadFitnessData(req)
        }
        throw Abort(.badRequest, reason: "Invalid data format.")
    }

    func fetchData(_ req: Request) async throws -> [String: Any] {
        let userId = try req.query.get(String.self, at: "userId")
        let healthData = try await healthDataController.fetchHealthData(req)
        let fitnessData = try await fitnessDataController.fetchFitnessData(req)
        return [
            "healthData": healthData,
            "fitnessData": fitnessData
        ]
    }
}
