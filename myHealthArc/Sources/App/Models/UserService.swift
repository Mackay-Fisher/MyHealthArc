import Fluent
import Vapor

final class UserService: Model, Content {
    static let schema = "user_services"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "user_hash")
    var userHash: String

    @Field(key: "selected_services")
    var selectedServices: [String: Bool]

    @Field(key: "is_face_id_enabled")
    var isFaceIDEnabled: Bool

    init() { }

    init(
        id: UUID? = nil,
        userHash: String,
        selectedServices: [String: Bool] = [:], // Default to empty dictionary
        isFaceIDEnabled: Bool = false // Default to false
    ) {
        self.id = id
        self.userHash = userHash
        self.selectedServices = selectedServices
        self.isFaceIDEnabled = isFaceIDEnabled
    }
}

