import Fluent
import Vapor

final class UserService: Model, Content {
    static let schema = "user_services"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "selected_services")
    var selectedServices: [String: Bool]

    @Field(key: "is_face_id_enabled")
    var isFaceIDEnabled: Bool

    init() { }

    init(id: UUID? = nil, userID: UUID, selectedServices: [String: Bool], isFaceIDEnabled: Bool = false) {
        self.id = id
        self.$user.id = userID
        self.selectedServices = selectedServices
        self.isFaceIDEnabled = isFaceIDEnabled
    }
}
