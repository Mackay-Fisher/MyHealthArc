import Vapor
import Fluent

struct NutritionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let nutrition = routes.grouped("nutrition")
        nutrition.post("create", use: self.createNutrition)
        nutrition.get("info", use: self.getNutritionInfo)
    }

    @Sendable
    func createNutrition(req: Request) async throws -> HTTPStatus {
        let nutrition = try req.content.decode(Nutrition.self)
        try await nutrition.save(on: req.db)
        return .created
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
                    "proteinMinimum": round(item.proteinMinimum * 10) / 10,
                    "proteinMaximum": round(item.proteinMaximum * 10) / 10,
                    "carbohydratesMinimum": round(item.carbohydratesMinimum * 10) / 10,
                    "carbohydratesMaximum": round(item.carbohydratesMaximum * 10) / 10,
                    "fatsMinimum": round(item.fatsMinimum * 10) / 10,
                    "fatsMaximum": round(item.fatsMaximum * 10) / 10,
                    "caloriesMinimum": round(Double(item.caloriesMinimum) * 10) / 10,
                    "caloriesMaximum": round(Double(item.caloriesMaximum) * 10) / 10
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

            // Calculate nutrient/macro values from the first 15 food items
            if let macroRanges = calculateMacroRanges(from: foodDataResponse.foods) {
                let (proteinMinimum, proteinMaximum, carbohydratesMinimum, carbohydratesMaximum, fatsMinimum, fatsMaximum, caloriesMinimum, caloriesMaximum) = macroRanges

                // If valid nutrient data is found, save to the database and return rounded results
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

                let newNutritionItem = NutritionItem(
                    foodItem: foodName,
                    proteinMinimum: proteinMinimum,
                    proteinMaximum: proteinMaximum,
                    carbohydratesMinimum: carbohydratesMinimum,
                    carbohydratesMaximum: carbohydratesMaximum,
                    fatsMinimum: fatsMinimum,
                    fatsMaximum: fatsMaximum,
                    caloriesMinimum: caloriesMinimum,
                    caloriesMaximum: caloriesMaximum
                )
                try await newNutritionItem.save(on: req.db)

                return (foodName, roundedNutrition)
            }
        } catch {
            return (foodName, nil)
        }

        return (foodName, nil)
    }

    // Helper function to calculate nutrient/macro ranges
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

        proteinValues = filterOutliers(values: proteinValues)
        carbohydrateValues = filterOutliers(values: carbohydrateValues)
        fatValues = filterOutliers(values: fatValues)
        calorieValues = filterOutliers(values: calorieValues.map { Double($0) }).map { Int($0) }

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

    // Helper function to filter outliers using IQR method
    private func filterOutliers(values: [Double]) -> [Double] {
        guard values.count > 4 else { return values }

        let sortedValues = values.sorted()
        let q1 = sortedValues[sortedValues.count / 4]
        let q3 = sortedValues[3 * sortedValues.count / 4]
        let iqr = q3 - q1

        let lowerBound = q1 - 1.5 * iqr
        let upperBound = q3 + 1.5 * iqr

        return sortedValues.filter { $0 >= lowerBound && $0 <= upperBound }
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
