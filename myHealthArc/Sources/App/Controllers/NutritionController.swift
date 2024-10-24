import Vapor
import Fluent

struct NutritionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let nutrition = routes.grouped("nutrition")
        nutrition.get("info", use: self.getNutritionInfo)
    }

    @Sendable
    func getNutritionInfo(req: Request) async throws -> [String: [String: Double]] {
        // Decode the list of food names from query parameter
        guard let foodNamesParam = try? req.query.get(String.self, at: "query") else {
            throw Abort(.badRequest, reason: "A 'query' parameter is required, with comma-separated food names.")
        }
        
        let foodNames = foodNamesParam.split(separator: ",").map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
        var nutritionResults: [String: [String: Double]] = [:]

        // Query existing items in the database with partial matching
        let existingItems = try await NutritionItem.query(on: req.db)
            .filter(\.$foodItem ~~ foodNames)
            .all()

        let existingFoodNames = existingItems.map { $0.foodItem.lowercased() }
        let missingFoodNames = foodNames.filter { name in
            !existingFoodNames.contains { $0.contains(name) }
        }

        // Add existing nutrition data to results
        for item in existingItems {
            nutritionResults[item.foodItem] = [
                "protein": item.protein,
                "carbohydrates": item.carbohydrates,
                "fats": item.fats,
                "calories": Double(item.calories)
            ]
        }

        // Fetch missing items from API and update the database
        if !missingFoodNames.isEmpty {
            let apiKey = Environment.get("FOOD_DATA_API_KEY") ?? "DEMO_KEY"

            for foodName in missingFoodNames {
                let url = "https://api.nal.usda.gov/fdc/v1/foods/search?query=\(foodName)&pageSize=1&api_key=\(apiKey)"
                let response = try await req.client.get(URI(string: url))

                guard let body = response.body,
                      let bodyData = body.getData(at: 0, length: body.readableBytes) else {
                    throw Abort(.internalServerError, reason: "Failed to get data for \(foodName) from FoodData Central API.")
                }

                let foodDataResponse = try JSONDecoder().decode(FoodDataResponse.self, from: bodyData)

                if let firstItem = foodDataResponse.foods.first {
                    // Extract nutrients from foodNutrients array
                    var protein: Double = 0.0
                    var carbohydrates: Double = 0.0
                    var fats: Double = 0.0
                    var calories: Int = 0

                    for nutrient in firstItem.foodNutrients {
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

                    // Add to results
                    let foodKey = firstItem.description.lowercased()
                    nutritionResults[foodKey] = [
                        "protein": protein,
                        "carbohydrates": carbohydrates,
                        "fats": fats,
                        "calories": Double(calories)
                    ]

                    // Save the new item to the database
                    let newNutritionItem = NutritionItem(
                        foodItem: foodKey,
                        protein: protein,
                        carbohydrates: carbohydrates,
                        fats: fats,
                        calories: calories
                    )
                    try await newNutritionItem.save(on: req.db)
                }
            }
        }

        return nutritionResults
    }
}
