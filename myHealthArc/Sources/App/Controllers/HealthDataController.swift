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
        for data in healthDataArray {
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
            .filter(\HealthKitData.$userHash == userHash) // Explicitly specify the type
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
        existingData.userHash = updatedData.userHash
        existingData.date = updatedData.date
        existingData.height = updatedData.height
        existingData.bodyMass = updatedData.bodyMass
        existingData.bodyMassIndex = updatedData.bodyMassIndex
        existingData.heartRate = updatedData.heartRate
        existingData.bloodPressureSystolic = updatedData.bloodPressureSystolic
        existingData.bloodPressureDiastolic = updatedData.bloodPressureDiastolic
        existingData.respiratoryRate = updatedData.respiratoryRate
        existingData.bodyTemperature = updatedData.bodyTemperature
        existingData.stepCount = updatedData.stepCount
        existingData.distanceWalkingRunning = updatedData.distanceWalkingRunning
        existingData.flightsClimbed = updatedData.flightsClimbed
        existingData.activeEnergyBurned = updatedData.activeEnergyBurned
        existingData.exerciseTime = updatedData.exerciseTime
        existingData.dietaryEnergy = updatedData.dietaryEnergy
        existingData.protein = updatedData.protein
        existingData.carbohydrates = updatedData.carbohydrates
        existingData.fat = updatedData.fat
        existingData.calcium = updatedData.calcium
        existingData.iron = updatedData.iron
        existingData.potassium = updatedData.potassium
        existingData.sodium = updatedData.sodium
        existingData.sleepAnalysis = updatedData.sleepAnalysis
        existingData.timeAsleep = updatedData.timeAsleep
        existingData.workoutType = updatedData.workoutType
        existingData.workoutDuration = updatedData.workoutDuration
        existingData.workoutCaloriesBurned = updatedData.workoutCaloriesBurned
        existingData.workoutDistance = updatedData.workoutDistance
        
        // Save the updated entry
        try await existingData.save(on: req.db)
        
        return .ok
    }
}
