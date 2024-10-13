// import Vapor

// struct NutritionController: RouteCollection {
//     func boot(routes: RoutesBuilder) throws {
//         let nutrition = routes.grouped("nutrition")
//         nutrition.get("info", use: self.getNutritionInfo)
//     }

//     func getNutritionInfo(req: Request) async throws -> NutritionData {
//         // Decode the food name from query parameter
//         guard let foodName = try? req.query.get(String.self, at: "query") else {
//             throw Abort(.badRequest, reason: "A 'query' parameter is required.")
//         }

//         // Build the API request URL
//         let apiKey = Environment.get("FOOD_DATA_API_KEY") ?? "Your_API_Key"
//         let url = "https://api.nal.usda.gov/fdc/v1/foods/search?query=\(foodName)&pageSize=1&api_key=\(apiKey)"

//         // Make the HTTP request
//         let response = try await req.client.get(URI(string: url))

//         guard let body = response.body,
//               let bodyData = body.getData(at: 0, length: body.readableBytes) else {
//             throw Abort(.internalServerError, reason: "Failed to get data from FoodData Central API.")
//         }

//         // Parse the response JSON
//         let nutritionData = try JSONDecoder().decode(FoodDataResponse.self, from: bodyData)
        
//         // Return the first food item data
//         guard let firstItem = nutritionData.foods.first else {
//             throw Abort(.notFound, reason: "No nutrition information found for \(foodName).")
//         }
        
//         return firstItem
//     }
// }
