import Vapor
import Fluent
import Crypto

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("user")
        userRoutes.post("signup", use: addUser)
    }

    func addUser(req: Request) async throws -> HTTPStatus {
        struct SignupData: Content {
            var email: String
            var password: String
            var fullName: String
        }

        let signupData = try req.content.decode(SignupData.self)
        let passwordHash = try Bcrypt.hash(signupData.password)

        let newUser = User(email: signupData.email, passwordHash: passwordHash, fullName: signupData.fullName)
        
        // Check if the email is already registered
        if try await User.query(on: req.db).filter(\.$email == signupData.email).first() != nil {
            throw Abort(.conflict, reason: "Email is already registered.")
        }
        
        // Save the user
        try await newUser.create(on: req.db)
        return .created
    }
}


//Need tyo add by the email to chekc if the user is already registered
