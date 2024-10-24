//
//  NutritionWidgetView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/23/24.
//


import SwiftUI
//NOTE: this is for the actual api stuff
// I created test code for the ui
//TODO: just uncomment this and comment out the other function


/*struct NutritionWidgetView: View {
    @State private var foodSearch: String = ""
    @State private var foodInfo: String = ""
    @State private var showFoodInfo: Bool = false

    var body: some View {
        VStack {
            Text("Nutrition Search")
                .font(.headline)
                .padding(.top)

            // Food search input
            TextField("Search for food", text: $foodSearch, onCommit: {
                fetchFoodInfo()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

            // Display food info
            if showFoodInfo {
                Text(foodInfo)
                    .padding()
            }

            // Button to navigate to Nutrition page
            NavigationLink(destination: NutritionView()) {
                Text("Go to Nutrition Page")
                    .padding()
                    .background(Color.mhaGreen)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 0.5)
    }

    private func fetchFoodInfo() {
        // Replace
        //gpt generated sample
        let urlString = "https://api.example.com/food?name=\(foodSearch)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let decodedData = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    foodInfo = decodedData // Parse the response as needed
                    showFoodInfo = true
                }
            }
        }.resume()
    }
}

struct NutritionWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionWidgetView()
    }
}*/

import SwiftUI

struct NutritionWidgetView: View {
    @State private var foodSearch: String = ""
    @State private var foodInfo: FoodItem?

    var body: some View {
        VStack {
            Text("Nutrition Search")
                .font(.headline)
                .padding(.top)

            // Food search input
            TextField("Search for food", text: $foodSearch, onCommit: {
                fetchFoodInfo()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

            // Display food info
            if let foodInfo = foodInfo {
                VStack(alignment: .leading) {
                    Text("Food: \(foodInfo.name)")
                        .font(.headline)
                    Text("Calories: \(foodInfo.calories)")
                    Text("Protein: \(foodInfo.protein) g")
                    Text("Carbs: \(foodInfo.carbs) g")
                    Text("Fats: \(foodInfo.fats) g")
                }
                .padding()
            }

            // Button to navigate to Nutrition page
            NavigationLink(destination: NutritionView()) {
                Text("Go to Nutrition Page")
                    .padding()
                    .background(Color.mhaGreen)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 0.5)
    }

    private func fetchFoodInfo() {
        // Simulating an API call with mock data
        if let food = mockFoodData.first(where: { $0.name.lowercased() == foodSearch.lowercased() }) {
            foodInfo = food
        } else {
            foodInfo = nil // No match found
        }
    }
}

struct NutritionWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionWidgetView()
    }
}

