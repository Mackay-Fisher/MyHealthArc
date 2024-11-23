import Fluent
import Vapor

struct UserServiceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userServices = routes.grouped("user-services")
        userServices.get("fetch", use: fetchUserServices)
        userServices.post("update", use: updateUserServices)
    }

    // MARK: - Fetch User Services
    func fetchUserServices(req: Request) async throws -> ServiceResponse {
        // Get the `userHash` from the query parameters
        guard let userHash = try? req.query.get(String.self, at: "userHash") else {
            throw Abort(.badRequest, reason: "'userHash' must be provided as a query parameter.")
        }

        // Attempt to fetch the user service by `userHash`
        if let userService = try await UserService.query(on: req.db)
            .filter(\.$userHash == userHash)
            .first() {
            // If a record exists, return the data
            return ServiceResponse(
                selectedServices: userService.selectedServices,
                isFaceIDEnabled: userService.isFaceIDEnabled
            )
        } else {
            // Create a new default record if none exists
            let newUserService = UserService(
                userHash: userHash,
                selectedServices: [:], // Default to empty selected services
                isFaceIDEnabled: false // Default FaceID to false
            )
            try await newUserService.save(on: req.db)

            // Log the creation and return the default response
            req.logger.info("Created new user service entry for userHash: \(userHash)")
            return ServiceResponse(
                selectedServices: newUserService.selectedServices,
                isFaceIDEnabled: newUserService.isFaceIDEnabled
            )
        }
    }

    // MARK: - Update User Services
    func updateUserServices(req: Request) async throws -> HTTPStatus {
        // Decode the incoming request body
        let requestBody = try req.content.decode(ServiceRequest.self)

        // Attempt to fetch the user service by `userHash`
        if let existingUserService = try await UserService.query(on: req.db)
            .filter(\.$userHash == requestBody.userHash)
            .first() {
            // Update the existing record
            existingUserService.selectedServices = requestBody.selectedServices
            existingUserService.isFaceIDEnabled = requestBody.isFaceIDEnabled
            try await existingUserService.save(on: req.db)
            req.logger.info("Updated existing user service for userHash: \(requestBody.userHash)")
        } else {
            // Create a new record if none exists
            let newUserService = UserService(
                userHash: requestBody.userHash,
                selectedServices: requestBody.selectedServices,
                isFaceIDEnabled: requestBody.isFaceIDEnabled
            )
            try await newUserService.save(on: req.db)
            req.logger.info("Created new user service for userHash: \(requestBody.userHash)")
        }

        return .ok
    }
}

// MARK: - Request and Response Models
struct ServiceRequest: Content {
    var userHash: String
    var selectedServices: [String: Bool]
    var isFaceIDEnabled: Bool
}

struct ServiceResponse: Content {
    var selectedServices: [String: Bool]
    var isFaceIDEnabled: Bool
}
