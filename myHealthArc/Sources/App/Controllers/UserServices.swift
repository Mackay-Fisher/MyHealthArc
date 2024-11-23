import Fluent
import Vapor

struct UserServiceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userServices = routes.grouped("user-services")
        userServices.post(use: self.createUserServices) // POST /user-services
        userServices.put(":userID", use: self.updateUserServices) // PUT /user-services/:userID
        userServices.get(":userID", use: self.getUserServices) // GET /user-services/:userID
    }
    
    // Create user services entry
    func createUserServices(req: Request) async throws -> UserService {
        let serviceDTO = try req.content.decode(UserServiceDTO.self)
        
        guard let user = try await User.find(serviceDTO.userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found.")
        }
        
        let userService = UserService(
            userID: try user.requireID(),
            selectedServices: serviceDTO.selectedServices
        )
        
        try await userService.save(on: req.db)
        return userService
    }
    
    // Update existing user services
    func updateUserServices(req: Request) async throws -> UserService {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid userID.")
        }
        
        guard let userService = try await UserService.query(on: req.db)
            .filter(\.$user.$id == userID)
            .first() else {
            throw Abort(.notFound, reason: "User services not found.")
        }
        
        let serviceDTO = try req.content.decode(UserServiceDTO.self)
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
