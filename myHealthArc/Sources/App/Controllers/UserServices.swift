import Fluent
import Vapor

struct UserServiceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userServices = routes.grouped("user-services")
        userServices.post(use: self.updateUserServices) // POST /user-services
        userServices.get(":userID", use: self.getUserServices) // GET /user-services/:userID
    }
    
    // Update (or create) user services
    func updateUserServices(req: Request) async throws -> UserService {
        let serviceDTO = try req.content.decode(UserServiceDTO.self)
        
        guard let user = try await User.find(serviceDTO.userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found.")
        }
        
        // Find existing user services or create a new one
        let userService = try await UserService.query(on: req.db)
            .filter(\.$user.$id == serviceDTO.userID)
            .first() ?? UserService(
                userID: try user.requireID(),
                selectedServices: serviceDTO.selectedServices
            )
        
        // Update selected services
        userService.selectedServices = serviceDTO.selectedServices
        
        try await userService.save(on: req.db)
        return userService
    }
    
    // Get user services
    func getUserServices(req: Request) async throws -> UserServiceDTO {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid userID.")
        }
        
        guard let userService = try await UserService.query(on: req.db)
            .filter(\.$user.$id == userID)
            .first() else {
            throw Abort(.notFound, reason: "User services not found.")
        }
        
        return UserServiceDTO(
            userID: userService.$user.id,
            selectedServices: userService.selectedServices
        )
    }
}

// DTO for user services
struct UserServiceDTO: Content {
    var userID: UUID
    var selectedServices: [String: Bool]
}
