import Vapor
import Crypto

struct LoginDTO: Content {
    var email: String
    var password: String
}