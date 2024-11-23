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
        guard let userId = try? req.query.get(String.self, at: "userId") else {
            throw Abort(.badRequest, reason: "'userId' must be provided as a query parameter.")
        }

        guard let userUUID = UUID(uuidString: userId) else {
            throw Abort(.badRequest, reason: "Invalid userId format. Must be a valid UUID.")
        }

        guard let userService = try await UserService.query(on: req.db)
            .filter(\.$user.$id == userUUID)
            .first() else {
            throw Abort(.notFound, reason: "User services not found for the provided userId.")
        }

        return ServiceResponse(
            selectedServices: userService.selectedServices,
            isFaceIDEnabled: userService.isFaceIDEnabled
        )
    }

    // MARK: - Update User Services
    func updateUserServices(req: Request) async throws -> HTTPStatus {
        let requestBody = try req.content.decode(ServiceRequest.self)

        guard let userUUID = UUID(uuidString: requestBody.userId) else {
            throw Abort(.badRequest, reason: "Invalid userId format. Must be a valid UUID.")
        }

        guard let user = try await User.find(userUUID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found.")
        }

        let userService = try await UserService.query(on: req.db)
            .filter(\.$user.$id == user.requireID())
            .first() ?? UserService(
                userID: try user.requireID(),
                selectedServices: requestBody.selectedServices,
                isFaceIDEnabled: requestBody.isFaceIDEnabled
            )

        userService.selectedServices = requestBody.selectedServices
        userService.isFaceIDEnabled = requestBody.isFaceIDEnabled

        try await userService.save(on: req.db)
        return .ok
    }
}

// MARK: - Request and Response Models
struct ServiceRequest: Content {
    var userId: String
    var selectedServices: [String: Bool]
    var isFaceIDEnabled: Bool
}

struct ServiceResponse: Content {
    var selectedServices: [String: Bool]
    var isFaceIDEnabled: Bool
}
