import Vapor
import Crypto

struct UserDTO: Content {
    var name: String
    var email: String
    var password: String
    
    func toModel() -> User {
        let passwordHash = try! Bcrypt.hash(self.password)
        let userHash = SHA256.hash(data: Data(self.email.utf8)).hexEncodedString()
        
        return User(
            name: self.name,
            email: self.email,
            passwordHash: passwordHash,
            userHash: userHash
        )
    }
}