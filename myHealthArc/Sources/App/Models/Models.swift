import Vapor
import Foundation

// Adjusted model for RxNorm ID response
struct ResponseData: Decodable {
    let types: [InteractionType]

    struct InteractionType: Decodable {
        let references: [Reference]
        
        struct Reference: Decodable {
            let id: String
        }
    }
}

// Adjusted response data structure for interaction data
struct InteractionResponse: Decodable {
    let errorCode: Int
    let multiInteractions: [MultiInteraction]?
    
    struct MultiInteraction: Decodable {
        let id: Int
        let subject: String
        let object: String
        let text: String
        let severityId: Int
        let severity: String
    }
}

// Struct for each interaction detail
struct FormattedInteraction: Content {
    let severity: String
    let interaction: String
    let description: String
    let note: String?
}

// Struct for the final formatted JSON response grouped by severity
struct FormattedInteractionResponse: Content {
    let interactionsBySeverity: [String: [FormattedInteraction]]
}

// Response model for the food data search
struct FoodDataResponse: Content {
    let foods: [NutritionData]
}

// Individual food item structure
struct NutritionData: Content {
    let description: String
    let foodNutrients: [Nutrient]
}

// Nutrient structure for details on each nutrient
struct Nutrient: Content {
    let nutrientName: String
    let unitName: String
    let value: Double
}

