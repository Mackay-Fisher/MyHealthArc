import XCTest
import Fluent
import FluentMongoDriver
import Vapor
import MongoKitten
@testable import App

final class NutritionValidationTest: XCTestCase {
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
        nutritionCollection = mongoDB["nutrition_items"]
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testValidateApple() async throws {
        try await validateNutritionItem(foodName: "apple")
    }

    func testValidateOranges() async throws {
        try await validateNutritionItem(foodName: "oranges")
    }

    func testValidateButter() async throws {
        try await validateNutritionItem(foodName: "butter")
    }

    func testValidateBread() async throws {
        try await validateNutritionItem(foodName: "bread")
    }

    func testValidateSalmon() async throws {
        try await validateNutritionItem(foodName: "salmon")
    }

    private func validateNutritionItem(foodName: String) async throws {
        let apiKey = Environment.get("FOOD_DATA_API_KEY") ?? "DEMO_KEY"
        let req = Request(application: app, on: app.eventLoopGroup.next())

        print("Fetching nutrition info for \(foodName) from the API")
        let (apiFoodName, apiNutrition) = await fetchNutritionForFood(foodName: foodName, apiKey: apiKey, req: req)
        guard let apiNutrition = apiNutrition else {
            XCTFail("Failed to fetch nutrition information from the API")
            return
        }
        print("Fetched nutrition info from the API: \(apiNutrition)")

        print("Checking if \(foodName) already exists in the database")
        if let existingItem = try await nutritionCollection.findOne(["foodItem": foodName]).get() {
            print("\(foodName) exists in the database. Deleting \(foodName)")

            try await nutritionCollection.deleteOne(where: ["foodItem": foodName]).get()
            print("Deleted existing item for \(foodName)")
        } else {
            print("\(foodName) does not exist in the database")
        }

        print("Adding \(foodName) to the database with nutrition info: \(apiNutrition)")
        let newNutritionItem = NutritionItem(
            foodItem: foodName,
            proteinMinimum: apiNutrition["proteinMinimum"]!,
            proteinMaximum: apiNutrition["proteinMaximum"]!,
            carbohydratesMinimum: apiNutrition["carbohydratesMinimum"]!,
            carbohydratesMaximum: apiNutrition["carbohydratesMaximum"]!,
            fatsMinimum: apiNutrition["fatsMinimum"]!,
            fatsMaximum: apiNutrition["fatsMaximum"]!,
            caloriesMinimum: Int(apiNutrition["caloriesMinimum"]!),
            caloriesMaximum: Int(apiNutrition["caloriesMaximum"]!)
        )
        try await nutritionCollection.insertEncoded(newNutritionItem).get()
        print("Added \(foodName) to the database")

        print("Fetching \(foodName) from the database")
        guard let dbItem = try await nutritionCollection.findOne(["foodItem": foodName], as: NutritionItem.self).get() else {
            XCTFail("Failed to fetch the nutrition item from the database")
            return
        }
        print("Fetched \(foodName) from the database: \(dbItem)")

        print("Validating the nutrition information for \(foodName)")
        XCTAssertEqual(dbItem.proteinMinimum, newNutritionItem.proteinMinimum, "Protein minimum does not match")
        XCTAssertEqual(dbItem.proteinMaximum, newNutritionItem.proteinMaximum, "Protein maximum does not match")
        XCTAssertEqual(dbItem.carbohydratesMinimum, newNutritionItem.carbohydratesMinimum, "Carbohydrates minimum does not match")
        XCTAssertEqual(dbItem.carbohydratesMaximum, newNutritionItem.carbohydratesMaximum, "Carbohydrates maximum does not match")
        XCTAssertEqual(dbItem.fatsMinimum, newNutritionItem.fatsMinimum, "Fats minimum does not match")
        XCTAssertEqual(dbItem.fatsMaximum, newNutritionItem.fatsMaximum, "Fats maximum does not match")
        XCTAssertEqual(dbItem.caloriesMinimum, newNutritionItem.caloriesMinimum, "Calories minimum does not match")
        XCTAssertEqual(dbItem.caloriesMaximum, newNutritionItem.caloriesMaximum, "Calories maximum does not match")
        print("Validation completed successfully for \(foodName)")
    }

    private func fetchNutritionForFood(foodName: String, apiKey: String, req: Request) async -> (String, [String: Double]?) {
        let url = "https://api.nal.usda.gov/fdc/v1/foods/search?query=\(foodName)&pageSize=15&api_key=\(apiKey)"
        
        do {
            let response = try await req.client.get(URI(string: url))
            guard let body = response.body,
                  let bodyData = body.getData(at: 0, length: body.readableBytes) else {
                return (foodName, nil)
            }

            let foodDataResponse = try JSONDecoder().decode(FoodDataResponse.self, from: bodyData)

            if let macroRanges = calculateMacroRanges(from: foodDataResponse.foods) {
                let (proteinMinimum, proteinMaximum, carbohydratesMinimum, carbohydratesMaximum, fatsMinimum, fatsMaximum, caloriesMinimum, caloriesMaximum) = macroRanges

                let roundedNutrition = [
                    "proteinMinimum": round(proteinMinimum * 10) / 10,
                    "proteinMaximum": round(proteinMaximum * 10) / 10,
                    "carbohydratesMinimum": round(carbohydratesMinimum * 10) / 10,
                    "carbohydratesMaximum": round(carbohydratesMaximum * 10) / 10,
                    "fatsMinimum": round(fatsMinimum * 10) / 10,
                    "fatsMaximum": round(fatsMaximum * 10) / 10,
                    "caloriesMinimum": round(Double(caloriesMinimum) * 10) / 10,
                    "caloriesMaximum": round(Double(caloriesMaximum) * 10) / 10
                ]

                return (foodName, roundedNutrition)
            }
        } catch {
            return (foodName, nil)
        }

        return (foodName, nil)
    }

    private func calculateMacroRanges(from foods: [FoodDataResponse.FoodItem]) -> (Double, Double, Double, Double, Double, Double, Int, Int)? {
        var proteinValues = [Double]()
        var carbohydrateValues = [Double]()
        var fatValues = [Double]()
        var calorieValues = [Int]()

        for foodItem in foods.prefix(15) {
            let (protein, carbs, fats, calories) = extractNutrientInfo(from: foodItem)
            if protein > 0 { proteinValues.append(protein) }
            if carbs > 0 { carbohydrateValues.append(carbs) }
            if fats > 0 { fatValues.append(fats) }
            if calories > 0 { calorieValues.append(calories) }
        }
        
        proteinValues = filterOutliers(values: proteinValues, nutrient: "protein")
        carbohydrateValues = filterOutliers(values: carbohydrateValues, nutrient: "carbohydrates")
        fatValues = filterOutliers(values: fatValues, nutrient: "fats")
        calorieValues = filterOutliers(values: calorieValues.map { Double($0) }, nutrient: "calories").map { Int($0) }

        guard !proteinValues.isEmpty,
              !carbohydrateValues.isEmpty,
              !fatValues.isEmpty,
              !calorieValues.isEmpty else { return nil }

        let proteinMinimum = proteinValues.min()!
        let proteinMaximum = proteinValues.max()!
        let carbohydratesMinimum = carbohydrateValues.min()!
        let carbohydratesMaximum = carbohydrateValues.max()!
        let fatsMinimum = fatValues.min()!
        let fatsMaximum = fatValues.max()!
        let caloriesMinimum = calorieValues.min()!
        let caloriesMaximum = calorieValues.max()!

        return (proteinMinimum, proteinMaximum, carbohydratesMinimum, carbohydratesMaximum, fatsMinimum, fatsMaximum, caloriesMinimum, caloriesMaximum)
    }

    private func filterOutliers(values: [Double], nutrient: String) -> [Double] {
        guard values.count > 4 else { return values }

        let sortedValues = values.sorted()
        let q1 = sortedValues[sortedValues.count / 4]
        let q3 = sortedValues[3 * sortedValues.count / 4]
        let iqr = q3 - q1

        let lowerBound = q1 - 1.5 * iqr
        let upperBound = q3 + 1.5 * iqr

        let filteredValues = sortedValues.filter { $0 >= lowerBound && $0 <= upperBound }
        let excludedValues = sortedValues.filter { $0 < lowerBound || $0 > upperBound }

        print("Excluded \(nutrient) values: \(excludedValues)")

        return filteredValues
    }

    private func extractNutrientInfo(from foodItem: FoodDataResponse.FoodItem) -> (Double, Double, Double, Int) {
        var protein: Double = 0.0
        var carbohydrates: Double = 0.0
        var fats: Double = 0.0
        var calories: Int = 0

        for nutrient in foodItem.foodNutrients {
            switch nutrient.nutrientName.lowercased() {
            case "protein":
                protein = nutrient.value
            case "carbohydrate, by difference":
                carbohydrates = nutrient.value
            case "total lipid (fat)":
                fats = nutrient.value
            case "energy" where nutrient.unitName.lowercased() == "kcal":
                calories = Int(nutrient.value)
            default:
                break
            }
        }

        return (protein, carbohydrates, fats, calories)
    }
}