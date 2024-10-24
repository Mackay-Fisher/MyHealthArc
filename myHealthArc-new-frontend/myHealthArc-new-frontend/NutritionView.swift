//
//  NutritionView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/23/24.
//


import SwiftUI
import SwiftUI

struct NutritionView: View {
    @State private var mealInput: String = ""
    @State private var meals: [String] = []
    @State private var foodSearch: String = ""
    @State private var foodInfo: String = ""
    @State private var showFoodInfo: Bool = false

    var body: some View {
        VStack {
            Text("Nutrition Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            // Meal Input Section
            HStack {
                TextField("Enter meal", text: $mealInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Add Meal") {
                    addMeal()
                }
                .padding()
                .background(Color.mhaGreen)
                .cornerRadius(8)
                .foregroundColor(.white)
            }

            // List of Recorded Meals
            List(meals, id: \.self) { meal in
                Text(meal)
            }
            .listStyle(PlainListStyle())
            .padding(.bottom)

            // Food Search Section
            HStack {
                TextField("Search for food", text: $foodSearch, onCommit: {
                    fetchFoodInfo()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: fetchFoodInfo) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.mhaPurple)
                        .clipShape(Circle())
                }
            }
            .padding()

            // Display Food Info
            if showFoodInfo {
                VStack(alignment: .leading) {
                    Text(foodInfo)
                        .font(.headline)
                        .padding(.bottom, 2)

                    Button(action: clearSearch) {
                        Text("Clear")
                            .padding()
                            .background(Color.mhaGreen)
                            .cornerRadius(50)
                            .foregroundColor(.white)
                    }
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .center) // Center button
                }
                .padding()
            }

            Spacer()
        }
        .padding()
    }

    // Add Meal Functionality
    private func addMeal() {
        guard !mealInput.isEmpty else { return }
        meals.append(mealInput)
        mealInput = ""
    }

    // Mock API Call to Fetch Food Info
    private func fetchFoodInfo() {
        let mockData: [String: String] = [
            "apple": "Apple - Calories: 95, Carbs: 25g, Protein: 0.5g, Fats: 0.3g",
            "banana": "Banana - Calories: 105, Carbs: 27g, Protein: 1.3g, Fats: 0.4g"
        ]

        if let info = mockData[foodSearch.lowercased()] {
            foodInfo = info
            showFoodInfo = true
        } else {
            foodInfo = "No information found."
            showFoodInfo = true
        }
    }

    // Clear Search Functionality
    private func clearSearch() {
        foodSearch = ""
        foodInfo = ""
        showFoodInfo = false
    }
}

// Preview for SwiftUI Canvas
struct NutritionView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionView()
    }
}
