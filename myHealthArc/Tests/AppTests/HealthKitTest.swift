@testable import App
import XCTVapor
import Fluent
import FluentMongoDriver
import MongoKitten

final class HealthKitTestTests: XCTestCase {
    var app: Application!
    var healthDataCollection: MongoKitten.MongoCollection!
    var fitnessDataCollection: MongoKitten.MongoCollection!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
        guard let databaseURL = Environment.get("DATABASE_URL") else {
            XCTFail("DATABASE_URL not set")
            return
        }
        let mongoDB = try await MongoDatabase.connect(databaseURL, on: app.eventLoopGroup.next()).get()
        healthDataCollection = mongoDB["health_data"]
        fitnessDataCollection = mongoDB["fitness_data"]
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testUpdateHealthData() async throws {
        let healthData = HealthData(type: "heartRate", value: 72.0, date: Date())
        let payload = HealthDataModel(userHash: "testUser1", data: [healthData])

        try await app.test(.POST, "/healthFitness/updateHealth", beforeRequest: { req in
            try req.content.encode(payload)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })

        guard let dbItem = try await healthDataCollection.findOne(["userHash": "testUser1"], as: HealthDataModel.self).get() else {
            XCTFail("Failed to fetch the health data document from the database")
            return
        }

        XCTAssertEqual(dbItem.userHash, payload.userHash)
        XCTAssertEqual(dbItem.data.first?.type, healthData.type)
        XCTAssertEqual(dbItem.data.first?.value, healthData.value)

        try await healthDataCollection.deleteOne(where: ["userHash": "testUser1"]).get()
    }

    func testUpdateFitnessData() async throws {
        let fitnessData = FitnessData(type: "steps", value: 1000.0, date: Date())
        let payload = FitnessDataModel(userHash: "testUser2", data: [fitnessData])

        try await app.test(.POST, "/healthFitness/updateFitness", beforeRequest: { req in
            try req.content.encode(payload)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })

        guard let dbItem = try await fitnessDataCollection.findOne(["userHash": "testUser2"], as: FitnessDataModel.self).get() else {
            XCTFail("Failed to fetch the fitness data document from the database")
            return
        }

        XCTAssertEqual(dbItem.userHash, payload.userHash)
        XCTAssertEqual(dbItem.data.first?.type, fitnessData.type)
        XCTAssertEqual(dbItem.data.first?.value, fitnessData.value)

        try await fitnessDataCollection.deleteOne(where: ["userHash": "testUser2"]).get()
    }
}