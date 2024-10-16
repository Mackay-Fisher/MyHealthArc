import Vapor
import Foundation

struct ResponseData: Decodable {
    let types: [InteractionType]

    struct InteractionType: Decodable {
        let references: [Reference]
        
        struct Reference: Decodable {
            let id: String
        }
    }
}

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

struct FormattedInteraction: Content {
    let severity: String
    let interaction: String
    let description: String
    let note: String?
}

struct FormattedInteractionResponse: Content {
    let interactionsBySeverity: [String: [FormattedInteraction]]
}

struct FoodDataResponse: Content {
    let foods: [NutritionData]
}

struct NutritionData: Content {
    let description: String
    let foodNutrients: [Nutrient]
}

struct Nutrient: Content {
    let nutrientName: String
    let unitName: String
    let value: Double
}

