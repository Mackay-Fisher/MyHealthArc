import Vapor
import Fluent

struct HealthFitnessDataController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let healthFitness = routes.grouped("healthFitness")
        healthFitness.post("updateHealth", use: self.updateHealthData)
        healthFitness.post("updateFitness", use: self.updateFitnessData)
        healthFitness.get("loadHealth", use: self.loadHealthData)
        healthFitness.get("loadFitness", use: self.loadFitnessData)
    }

    // MARK: - Update Health Data
    func updateHealthData(req: Request) async throws -> HTTPStatus {
    struct HealthPayload: Content {
        let userHash: String
        let data: [HealthData]
    }
    let payload = try req.content.decode(HealthPayload.self)

    if let existingData = try await HealthDataModel.query(on: req.db)
        .filter(\.$userHash == payload.userHash)
        .first() {
        // Append new health data
        existingData.data.append(contentsOf: payload.data)
        try await existingData.save(on: req.db)
    } else {
        // Create a new health data record
        let newData = HealthDataModel(userHash: payload.userHash, data: payload.data)
        try await newData.save(on: req.db)
    }
    return .ok
}


    // MARK: - Update Fitness Data
    func updateFitnessData(req: Request) async throws -> HTTPStatus {
    struct FitnessPayload: Content {
        let userHash: String
        let data: [FitnessData]
    }
    let payload = try req.content.decode(FitnessPayload.self)

    if let existingData = try await FitnessDataModel.query(on: req.db)
        .filter(\.$userHash == payload.userHash)
        .first() {
        // Append new fitness data
        existingData.data.append(contentsOf: payload.data)
        try await existingData.save(on: req.db)
    } else {
        // Create a new fitness data record
        let newData = FitnessDataModel(userHash: payload.userHash, data: payload.data)
        try await newData.save(on: req.db)
    }
    return .ok
}


    // MARK: - Load Health Data
    func loadHealthData(req: Request) async throws -> HealthDataModel {
        guard let userHash = req.query[String.self, at: "userHash"] else {
            throw Abort(.badRequest, reason: "User hash not provided.")
        }

        guard let data = try await HealthDataModel.query(on: req.db)
            .filter(\.$userHash == userHash)
            .first() else {
            throw Abort(.notFound, reason: "No health data found for the given user.")
        }

        return data
    }

    // MARK: - Load Fitness Data
    func loadFitnessData(req: Request) async throws -> FitnessDataModel {
    guard let userHash = req.query[String.self, at: "userHash"] else {
        throw Abort(.badRequest, reason: "User hash not provided.")
    }

    guard let data = try await FitnessDataModel.query(on: req.db)
        .filter(\.$userHash == userHash)
        .first() else {
        throw Abort(.notFound, reason: "No fitness data found for the given user.")
    }

    return data // Safely unwrapped
}

}
