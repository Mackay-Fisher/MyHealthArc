import Vapor

struct HealthKitDataController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let healthData = routes.grouped("healthData")
        
        // Define routes for each operation
        healthData.post("summary", use: createHealthData)
        healthData.get("summary", ":userHash", use: getHealthData)
        healthData.put("summary", ":id", use: updateHealthData)
    }

    // POST request to create health data entries
    func createHealthData(req: Request) async throws -> HTTPStatus {
        // Decode an array of HealthKitData entries
        let healthDataArray = try req.content.decode([HealthKitData].self)
        
        // Save each HealthKitData entry to the database
        try await healthDataArray.forEach { data in
            try await data.save(on: req.db)
        }
        
        return .created
    }
    
    // GET request to retrieve health data for a specific user by userHash
    func getHealthData(req: Request) async throws -> [HealthKitData] {
        // Extract userHash parameter from the request
        guard let userHash = req.parameters.get("userHash") else {
            throw Abort(.badRequest, reason: "Missing userHash parameter")
        }
        
        // Query health data for the specified user
        return try await HealthKitData.query(on: req.db)
            .filter(\.$userHash == userHash)
            .all()
    }
    
    // PUT request to update a specific health data entry by id
    func updateHealthData(req: Request) async throws -> HTTPStatus {
        // Extract the id of the health data entry from the request
        guard let id = req.parameters.get("id"), let uuid = UUID(uuidString: id) else {
            throw Abort(.badRequest, reason: "Invalid or missing id parameter")
        }
        
        // Fetch the health data entry from the database
        guard let existingData = try await HealthKitData.find(uuid, on: req.db) else {
            throw Abort(.notFound, reason: "Health data entry not found")
        }
        
        // Decode the updated fields from the request
        let updatedData = try req.content.decode(HealthKitData.self)
        
        // Update the fields
        existingData.steps = updatedData.steps
        existingData.heartRate = updatedData.heartRate
        existingData.hoursSleep = updatedData.hoursSleep
        existingData.date = updatedData.date
        
        // Save the updated entry
        try await existingData.save(on: req.db)
        
        return .ok
    }
}
