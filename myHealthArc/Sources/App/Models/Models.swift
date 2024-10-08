import Foundation

// Response Data for RxNorm ID
struct ResponseData: Decodable {
    let interactions: [Type]

    struct Type: Decodable {
        let references: [Reference]
        
        struct Reference: Decodable {
            let id: String
        }
    }
}

// Response Data for Interactions
struct InteractionResponse: Decodable {
    let errorCode: Int
    let multiInteractions: [MultiInteraction]?
    
    struct MultiInteraction: Decodable {
        let severityId: Int
        let severity: String
        let text: String
    }
}

// Response Data Structure for FoodData Central API
struct FoodDataResponse: Decodable {
    let foods: [NutritionData]
}

// Individual Food Item Structure
struct NutritionData: Content, Decodable {
    let description: String
    let foodNutrients: [Nutrient]
    
    struct Nutrient: Decodable {
        let nutrientName: String
        let value: Double
        let unitName: String
    }
}
