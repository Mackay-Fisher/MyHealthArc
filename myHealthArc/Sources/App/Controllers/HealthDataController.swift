import Vapor

struct HealthDataController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let healthData = routes.grouped("healthData")
        healthData.post("upload", use: uploadHealthData)
    }

    // Endpoint for iOS app to upload health data
    func uploadHealthData(req: Request) async throws -> HTTPStatus {
        let healthData = try req.content.decode([HealthData].self)
        
        // Log or store the health data as needed
        print("Received Health Data:", healthData)
        
        // If you want to save to a database, insert save logic here
        // e.g., healthData.save(on: req.db)

        return .ok
    }
}

// Model for health data entries
struct HealthData: Content {
    var type: String
    var value: Double
}
