import XCTest
import Fluent
import FluentMongoDriver
import Vapor
import MongoKitten
import XCTVapor
@testable import App

final class UserServicesTest: XCTestCase {
    var app: Application!
    var userServiceCollection: MongoKitten.MongoCollection!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
        guard let databaseURL = Environment.get("DATABASE_URL") else {
            XCTFail("DATABASE_URL not set")
            return
        }
        let mongoDB = try await MongoDatabase.connect(databaseURL, on: app.eventLoopGroup.next()).get()
        userServiceCollection = mongoDB["user_services"]
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testFetchUserServices() async throws {
        let userHash = "testUserHash1"
        try await createUserService(userHash: userHash, selectedServices: ["service1": true], isFaceIDEnabled: true)

        try await app.test(.GET, "/user-services/fetch?userHash=\(userHash)", afterResponse: { res in
            XCTAssertEqual(res.status, .ok, "Failed to fetch user services")
            let serviceResponse = try res.content.decode(ServiceResponse.self)
            XCTAssertEqual(serviceResponse.selectedServices["service1"], true, "Selected services do not match")
            XCTAssertEqual(serviceResponse.isFaceIDEnabled, true, "FaceID status does not match")
        })

        try await deleteUserService(userHash: userHash)
    }

    private func createUserService(userHash: String, selectedServices: [String: Bool], isFaceIDEnabled: Bool) async throws {
        let newUserService = UserService(userHash: userHash, selectedServices: selectedServices, isFaceIDEnabled: isFaceIDEnabled)
        try await newUserService.save(on: app.db)
    }

    private func deleteUserService(userHash: String) async throws {
        _ = try await userServiceCollection.deleteOne(where: ["userHash": userHash]).get()
    }
}