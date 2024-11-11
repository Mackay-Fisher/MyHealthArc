import Fluent
import Vapor
import Crypto

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post("signup", use: self.signup)
        users.post("login", use: self.login)
        users.get(":userHash", use: self.getUserByHash)
    }

    @Sendable
    func signup(req: Request) async throws -> User {
        let userDTO = try req.content.decode(UserDTO.self)
        let passwordHash = try Bcrypt.hash(userDTO.password)
        let userHash = SHA256.hash(data: Data(userDTO.email.utf8)).hexEncodedString()
        
        let user = User(
            fullName: userDTO.fullName,
            email: userDTO.email.lowercased(),
            passwordHash: passwordHash,
            userHash: userHash
        )

        if try await User.query(on: req.db).filter(\.$email == userDTO.email).first() != nil {
            throw Abort(.conflict, reason: "Email is already registered.")
        }
        
        try await user.save(on: req.db)
        return user
    }

    @Sendable
    func login(req: Request) async throws -> User {
        let loginDTO = try req.content.decode(LoginDTO.self)
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == loginDTO.email.lowercased())
            .first() else {
            throw Abort(.unauthorized, reason: "Invalid email or password")
        }
        
        let isPasswordValid = try Bcrypt.verify(loginDTO.password, created: user.passwordHash)
        guard isPasswordValid else {
            throw Abort(.unauthorized, reason: "Invalid email or password")
        }
        return user
    }

    @Sendable
    func getUserByHash(req: Request) async throws -> User {
        guard let userHash = req.parameters.get("userHash") else {
            throw Abort(.badRequest, reason: "Missing userHash parameter")
        }
        guard let user = try await User.query(on: req.db)
            .filter(\.$userHash == userHash)
            .first() else {
            throw Abort(.notFound, reason: "User not found")
        }
        return user
    }
}
