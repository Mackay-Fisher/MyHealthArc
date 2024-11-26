import XCTest
import Fluent
import FluentMongoDriver
import Vapor
import MongoKitten
import XCTVapor
@testable import App

final class NutritionEntryTest: XCTestCase {
    var app: Application!
    var nutritionCollection: MongoKitten.MongoCollection!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
        guard let databaseURL = Environment.get("DATABASE_URL") else {
            XCTFail("DATABASE_URL not set")
            return
        }
        let mongoDB = try await MongoDatabase.connect(databaseURL, on: app.eventLoopGroup.next()).get()
        nutritionCollection = mongoDB["nutrition"]
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testInsertNutrition1() async throws {
        try await insertNutrition(userHash: "user1", foodName: "Apple", proteinMinimum: 10.0, proteinMaximum: 20.0, carbohydratesMinimum: 10.0, carbohydratesMaximum: 20.0, fatsMinimum: 10.0, fatsMaximum: 20.0, caloriesMinimum: 100, caloriesMaximum: 200)
    }

    func testInsertNutrition2() async throws {
        try await insertNutrition(userHash: "user2", foodName: "Banana", proteinMinimum: 15.0, proteinMaximum: 25.0, carbohydratesMinimum: 15.0, carbohydratesMaximum: 25.0, fatsMinimum: 15.0, fatsMaximum: 25.0, caloriesMinimum: 150, caloriesMaximum: 250)
    }

    func testInsertNutrition3() async throws {
        try await insertNutrition(userHash: "user3", foodName: "Orange", proteinMinimum: 20.0, proteinMaximum: 30.0, carbohydratesMinimum: 20.0, carbohydratesMaximum: 30.0, fatsMinimum: 20.0, fatsMaximum: 30.0, caloriesMinimum: 200, caloriesMaximum: 300)
    }

    func testInsertNutrition4() async throws {
        try await insertNutrition(userHash: "user4", foodName: "Grapes", proteinMinimum: 25.0, proteinMaximum: 35.0, carbohydratesMinimum: 25.0, carbohydratesMaximum: 35.0, fatsMinimum: 25.0, fatsMaximum: 35.0, caloriesMinimum: 250, caloriesMaximum: 350)
    }

    func testInsertNutrition5() async throws {
        try await insertNutrition(userHash: "user5", foodName: "Mango", proteinMinimum: 50.0, proteinMaximum: 50.0, carbohydratesMinimum: 50.0, carbohydratesMaximum: 50.0, fatsMinimum: 50.0, fatsMaximum: 50.0, caloriesMinimum: 500, caloriesMaximum: 550)
    }

    private func insertNutrition(userHash: String, foodName: String, proteinMinimum: Double, proteinMaximum: Double, carbohydratesMinimum: Double, carbohydratesMaximum: Double, fatsMinimum: Double, fatsMaximum: Double, caloriesMinimum: Int, caloriesMaximum: Int) async throws {
        let newNutrition = Nutrition(
            userHash: userHash,
            foodName: foodName,
            proteinMinimum: proteinMinimum,
            proteinMaximum: proteinMaximum,
            carbohydratesMinimum: carbohydratesMinimum,
            carbohydratesMaximum: carbohydratesMaximum,
            fatsMinimum: fatsMinimum,
            fatsMaximum: fatsMaximum,
            caloriesMinimum: caloriesMinimum,
            caloriesMaximum: caloriesMaximum
        )

        print("Sending POST request to create the nutrition object for \(userHash)")
        try await app.test(.POST, "/nutrition/create", beforeRequest: { req in
            try req.content.encode(newNutrition)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created, "Failed to create nutrition object")
        })

        print("Fetching the nutrition object for \(userHash) from the database")
        guard let dbItem = try await nutritionCollection.findOne(["userHash": userHash], as: Nutrition.self).get() else {
            XCTFail("Failed to fetch the nutrition object from the database")
            return
        }

        XCTAssertEqual(dbItem.userHash, newNutrition.userHash, "User hash does not match")
        XCTAssertEqual(dbItem.foodName, newNutrition.foodName, "Food name does not match")
        XCTAssertEqual(dbItem.proteinMinimum, newNutrition.proteinMinimum, "Protein minimum does not match")
        XCTAssertEqual(dbItem.proteinMaximum, newNutrition.proteinMaximum, "Protein maximum does not match")
        XCTAssertEqual(dbItem.carbohydratesMinimum, newNutrition.carbohydratesMinimum, "Carbohydrates minimum does not match")
        XCTAssertEqual(dbItem.carbohydratesMaximum, newNutrition.carbohydratesMaximum, "Carbohydrates maximum does not match")
        XCTAssertEqual(dbItem.fatsMinimum, newNutrition.fatsMinimum, "Fats minimum does not match")
        XCTAssertEqual(dbItem.fatsMaximum, newNutrition.fatsMaximum, "Fats maximum does not match")
        XCTAssertEqual(dbItem.caloriesMinimum, newNutrition.caloriesMinimum, "Calories minimum does not match")
        XCTAssertEqual(dbItem.caloriesMaximum, newNutrition.caloriesMaximum, "Calories maximum does not match")
        print("Nutrition object validation completed successfully for \(userHash)")

        _ = try await nutritionCollection.deleteOne(where: ["userHash": userHash]).get()
        print("Deleted the nutrition object for \(userHash)")
    }
}