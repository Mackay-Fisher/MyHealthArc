import Vapor

struct NutritionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let nutrition = routes.grouped("nutrition")
        nutrition.get("info", use: self.getNutritionInfo)
    }

    @Sendable
    func getNutritionInfo(req: Request) async throws -> [NutritionData] {
        // Decode the list of food names from query parameter
        guard let foodNamesParam = try? req.query.get(String.self, at: "query") else {
            throw Abort(.badRequest, reason: "A 'query' parameter is required, with comma-separated food names.")
        }
        
        let foodNames = foodNamesParam.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        // API Key for the FoodData Central API
        let apiKey = Environment.get("FOOD_DATA_API_KEY") ?? "DEMO_KEY"
        var nutritionResults: [NutritionData] = []

        // Loop through each food name and fetch its nutrition information
        for foodName in foodNames {
            let url = "https://api.nal.usda.gov/fdc/v1/foods/search?query=\(foodName)&pageSize=1&api_key=\(apiKey)"
            let response = try await req.client.get(URI(string: url))
            guard let body = response.body,
                  let bodyData = body.getData(at: 0, length: body.readableBytes) else {
                throw Abort(.internalServerError, reason: "Failed to get data for \(foodName) from FoodData Central API.")
            }
            let foodDataResponse = try JSONDecoder().decode(FoodDataResponse.self, from: bodyData)
            
            // Check if there is at least one result and add it to the results array
            if let firstItem = foodDataResponse.foods.first {
                nutritionResults.append(firstItem)
            }
        }
        return nutritionResults
    }
}

