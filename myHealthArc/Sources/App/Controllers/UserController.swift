import Fluent
import Vapor
import Crypto

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: self.create)
    }

    @Sendable
    func create(req: Request) async throws -> User {
        let userDTO = try req.content.decode(UserDTO.self)
        let user = userDTO.toModel()
        
        try await user.save(on: req.db)
        return user
    }
}
