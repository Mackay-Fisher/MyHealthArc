//
//  FoodItem.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/23/24.
//

//gpt generated
import Foundation

struct FoodItem: Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fats: Double
}

let mockFoodData: [FoodItem] = [
    FoodItem(name: "Apple", calories: 95, protein: 0.5, carbs: 25, fats: 0.3),
    FoodItem(name: "Banana", calories: 105, protein: 1.3, carbs: 27, fats: 0.3),
    FoodItem(name: "Chicken Breast", calories: 165, protein: 31, carbs: 0, fats: 3.6),
    FoodItem(name: "Broccoli", calories: 55, protein: 3.7, carbs: 11, fats: 0.6),
    FoodItem(name: "Rice", calories: 206, protein: 4.3, carbs: 45, fats: 0.4)
]
