import Fluent
import Vapor
import Crypto

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: self.signup)
    }

    @Sendable
    func signup(req: Request) async throws -> User {
        let userDTO = try req.content.decode(UserDTO.self)
        let user = userDTO.toModel()
        
        try await user.save(on: req.db)
        return user
    }

    @Sendable
    func login(req: Request) async throws -> User {
        let loginDTO = try req.content.decode(LoginDTO.self)
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == loginDTO.email)
            .first() else {
            throw Abort(.unauthorized, reason: "Invalid email or password")
        }
        
        let isPasswordValid = try Bcrypt.verify(loginDTO.password, created: user.passwordHash)
        guard isPasswordValid else {
            throw Abort(.unauthorized, reason: "Invalid email or password")
        }
        return user
    }
}
