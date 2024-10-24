import Vapor
import Fluent

struct NutritionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let nutrition = routes.grouped("nutrition")
        nutrition.get("info", use: self.getNutritionInfo)
    }

    @Sendable
    func getNutritionInfo(req: Request) async throws -> [String: [String: Double]] {
        // Decode the list of food names from the query parameter
        guard let foodNamesParam = try? req.query.get(String.self, at: "query") else {
            throw Abort(.badRequest, reason: "A 'query' parameter is required, with comma-separated food names.")
        }

        // Normalize food names for partial matching
        let foodNames = foodNamesParam.split(separator: ",").map {
            $0.lowercased().trimmingCharacters(in: .whitespaces)
        }
        var nutritionResults: [String: [String: Double]] = [:]

        // Query existing items in the database with case-insensitive partial matching
        let existingItems = try await NutritionItem.query(on: req.db).all()
        let normalizedExistingItems = existingItems.map { (foodItem: $0.foodItem.lowercased(), item: $0) }

        // Separate found items from missing items
        var missingFoodNames = [String]()
        for foodName in foodNames {
            if let matchedItem = normalizedExistingItems.first(where: { $0.foodItem.contains(foodName) }) {
                // If a match is found, add it to the results
                let item = matchedItem.item
                nutritionResults[item.foodItem] = [
                    "protein": round(item.protein * 10) / 10,
                    "carbohydrates": round(item.carbohydrates * 10) / 10,
                    "fats": round(item.fats * 10) / 10,
                    "calories": round(Double(item.calories) * 10) / 10
                ]
            } else {
                // If no match is found, add to the list of missing items
                missingFoodNames.append(foodName)
            }
        }

        // Fetch missing items from the API concurrently
        if !missingFoodNames.isEmpty {
            let apiKey = Environment.get("FOOD_DATA_API_KEY") ?? "DEMO_KEY"

            // Fetch nutrition info concurrently for each missing food name
            await withTaskGroup(of: (String, [String: Double]?).self) { group in
                for foodName in missingFoodNames {
                    group.addTask {
                        await fetchNutritionForFood(foodName: foodName, apiKey: apiKey, req: req)
                    }
                }

                // Collect results from all concurrent fetches
                for await (foodName, nutrition) in group {
                    if let nutrition = nutrition {
                        nutritionResults[foodName] = nutrition
                    }
                }
            }
        }

        return nutritionResults
    }

    // Helper function to fetch nutrition for a food item from the API
    private func fetchNutritionForFood(foodName: String, apiKey: String, req: Request) async -> (String, [String: Double]?) {
        let url = "https://api.nal.usda.gov/fdc/v1/foods/search?query=\(foodName)&pageSize=15&api_key=\(apiKey)"
        
        do {
            let response = try await req.client.get(URI(string: url))
            guard let body = response.body,
                  let bodyData = body.getData(at: 0, length: body.readableBytes) else {
                return (foodName, nil)
            }

            let foodDataResponse = try JSONDecoder().decode(FoodDataResponse.self, from: bodyData)

            // Calculate average nutrient values from the first 15 food items
            if let averagedNutrients = calculateAverageNutrients(from: foodDataResponse.foods) {
                let (protein, carbohydrates, fats, calories) = averagedNutrients

                // If valid nutrient data is found, save to the database and return rounded results
                if protein > 0 || carbohydrates > 0 || fats > 0 || calories > 0 {
                    let roundedNutrition = [
                        "protein": round(protein * 10) / 10,
                        "carbohydrates": round(carbohydrates * 10) / 10,
                        "fats": round(fats * 10) / 10,
                        "calories": round(Double(calories) * 10) / 10
                    ]

                    // Save the new item to the database
                    let newNutritionItem = NutritionItem(
                        foodItem: foodName,
                        protein: protein,
                        carbohydrates: carbohydrates,
                        fats: fats,
                        calories: calories
                    )
                    try await newNutritionItem.save(on: req.db)

                    return (foodName, roundedNutrition)
                }
            }
        } catch {
            return (foodName, nil)
        }

        return (foodName, nil)
    }

    // Helper function to calculate average nutrient values
    private func calculateAverageNutrients(from foods: [FoodDataResponse.FoodItem]) -> (Double, Double, Double, Int)? {
        var totalProtein: Double = 0.0
        var totalCarbs: Double = 0.0
        var totalFats: Double = 0.0
        var totalCalories: Int = 0
        var count = 0

        // Iterate over the first 15 food items
        for foodItem in foods.prefix(15) {
            let (protein, carbs, fats, calories) = extractNutrientInfo(from: foodItem)

            // Add the nutrient values if they are valid
            if protein > 0 || carbs > 0 || fats > 0 || calories > 0 {
                totalProtein += protein
                totalCarbs += carbs
                totalFats += fats
                totalCalories += calories
                count += 1
            }
        }

        // Calculate averages
        guard count > 0 else { return nil }
        return (
            totalProtein / Double(count),
            totalCarbs / Double(count),
            totalFats / Double(count),
            totalCalories / count
        )
    }

    // Helper function to extract nutrient information from a food item
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
