import XCTest
import Fluent
import FluentMongoDriver
import Vapor
import MongoKitten
import XCTVapor
@testable import App

final class BodyDataTest: XCTestCase {
    var app: Application!
    var bodyDataCollection: MongoKitten.MongoCollection!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
        guard let databaseURL = Environment.get("DATABASE_URL") else {
            XCTFail("DATABASE_URL not set")
            return
        }
        let mongoDB = try await MongoDatabase.connect(databaseURL, on: app.eventLoopGroup.next()).get()
        bodyDataCollection = mongoDB["body_data"]
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testCreateBodyData() async throws {
        try await createBodyData(userHash: "user1", height: 180.0, weight: 75.0, age: 18, gender: "male", bmi: 23.1)
        try await deleteBodyData(userHash: "user1")
    }

    func testUpdateBodyData() async throws {
        try await createBodyData(userHash: "user2", height: 160.0, weight: 55.0, age: 20, gender: "female", bmi: 23.4)
        try await updateBodyData(userHash: "user2", height: 165.0, weight: 62.0, age: 31, gender: "female", bmi: 22.8)
        try await deleteBodyData(userHash: "user2")
    }

    func testLoadBodyData() async throws {
        try await createBodyData(userHash: "user3", height: 125.0, weight: 70.0, age: 28, gender: "male", bmi: 24.2)
        try await loadBodyData(userHash: "user3")
        try await deleteBodyData(userHash: "user3")
    }

    func testCreateAndUpdateBodyData() async throws {
        try await createBodyData(userHash: "user4", height: 175.0, weight: 45.0, age: 29, gender: "male", bmi: 21.2)
        try await updateBodyData(userHash: "user4", height: 180.0, weight: 70.0, age: 27, gender: "male", bmi: 22.5)
        try await deleteBodyData(userHash: "user4")
    }

    func testCreateAndLoadBodyData() async throws {
        try await createBodyData(userHash: "user5", height: 147.0, weight: 57.0, age: 24, gender: "female", bmi: 20.0)
        try await loadBodyData(userHash: "user5")
        try await deleteBodyData(userHash: "user5")
    }

    func testUpdateAndLoadBodyData() async throws {
        try await createBodyData(userHash: "user6", height: 165.0, weight: 60.0, age: 29, gender: "female", bmi: 22.0)
        try await updateBodyData(userHash: "user6", height: 188.0, weight: 65.0, age: 30, gender: "female", bmi: 23.0)
        try await loadBodyData(userHash: "user6")
        try await deleteBodyData(userHash: "user6")
    }

    private func createBodyData(userHash: String, height: Double, weight: Double, age: Int, gender: String, bmi: Double?) async throws {
        let newBodyData = BodyDataModel(
            userHash: userHash,
            height: height,
            weight: weight,
            age: age,
            gender: gender,
            bmi: bmi
        )

        print("Sending POST request to create the body data document for \(userHash)")
        try await app.test(.POST, "/bodyData/create", beforeRequest: { req in
            try req.content.encode(newBodyData)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created, "Failed to create body data document")
        })

        print("Fetching the body data document for \(userHash) from the database")
        guard let dbItem = try await bodyDataCollection.findOne(["userHash": userHash], as: BodyDataModel.self).get() else {
            XCTFail("Failed to fetch the body data document from the database")
            return
        }

        XCTAssertEqual(dbItem.userHash, newBodyData.userHash, "User hash does not match")
        XCTAssertEqual(dbItem.height, newBodyData.height, "Height does not match")
        XCTAssertEqual(dbItem.weight, newBodyData.weight, "Weight does not match")
        XCTAssertEqual(dbItem.age, newBodyData.age, "Age does not match")
        XCTAssertEqual(dbItem.gender, newBodyData.gender, "Gender does not match")
        XCTAssertEqual(dbItem.bmi, newBodyData.bmi, "BMI does not match")
        print("Body data document validation completed successfully for \(userHash)")
    }

    private func updateBodyData(userHash: String, height: Double, weight: Double, age: Int, gender: String, bmi: Double?) async throws {
        let updatedBodyData = BodyDataModel(
            userHash: userHash,
            height: height,
            weight: weight,
            age: age,
            gender: gender,
            bmi: bmi
        )

        print("Sending POST request to update the body data document for \(userHash)")
        try await app.test(.POST, "/bodyData/update", beforeRequest: { req in
            try req.content.encode(updatedBodyData)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok, "Failed to update body data document")
        })

        print("Fetching the updated body data document for \(userHash) from the database")
        guard let dbItem = try await bodyDataCollection.findOne(["userHash": userHash], as: BodyDataModel.self).get() else {
            XCTFail("Failed to fetch the updated body data document from the database")
            return
        }

        XCTAssertEqual(dbItem.userHash, updatedBodyData.userHash, "User hash does not match")
        XCTAssertEqual(dbItem.height, updatedBodyData.height, "Height does not match")
        XCTAssertEqual(dbItem.weight, updatedBodyData.weight, "Weight does not match")
        XCTAssertEqual(dbItem.age, updatedBodyData.age, "Age does not match")
        XCTAssertEqual(dbItem.gender, updatedBodyData.gender, "Gender does not match")
        XCTAssertEqual(dbItem.bmi, updatedBodyData.bmi, "BMI does not match")
        print("Updated body data document validation completed successfully for \(userHash)")
    }

    private func loadBodyData(userHash: String) async throws {
        print("Sending GET request to load the body data document for \(userHash)")
        try await app.test(.GET, "/bodyData/load?userHash=\(userHash)", afterResponse: { res in
            XCTAssertEqual(res.status, .ok, "Failed to load body data document")
            let bodyData = try res.content.decode(BodyDataModel.self)
            XCTAssertEqual(bodyData.userHash, userHash, "User hash does not match")
            print("Loaded body data document: \(bodyData)")
        })
    }

    private func deleteBodyData(userHash: String) async throws {
        print("Deleting the body data document for \(userHash) from the database")
        _ = try await bodyDataCollection.deleteOne(where: ["userHash": userHash]).get()
        print("Deleted the body data document for \(userHash)")
    }
}