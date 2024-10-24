import Vapor
import Crypto

struct UserDTO: Content {
    var fullName: String
    var email: String
    var password: String
    
    func toModel() -> User {
        let passwordHash = try! Bcrypt.hash(self.password)
        let userHash = SHA256.hash(data: Data(self.email.utf8)).hexEncodedString()
        
        return User(
            fullName: self.fullName,
            email: self.email,
            passwordHash: passwordHash,
            userHash: userHash
        )
    }
}