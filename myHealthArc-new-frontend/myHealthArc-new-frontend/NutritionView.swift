//
//  NutritionView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/23/24.
//


import SwiftUI
//NOTE: this is for the actual api stuff
// I created test code for the ui
//TODO: just uncomment this and comment out the other function

/*struct NutritionView: View {
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

            // Input for recording meals
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
            
            List(meals, id: \.self) { meal in
                Text(meal)
            }
            .listStyle(PlainListStyle())

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

            Spacer()
        }
        .padding()
    }

    private func addMeal() {
        guard !mealInput.isEmpty else { return }
        meals.append(mealInput)
        mealInput = ""
    }

    private func fetchFoodInfo() {
        // gpt created sample code
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


struct NutritionView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionView()
    }
}*/

//for testing ui
struct NutritionView: View {
    @State private var mealInput: String = ""
    @State private var meals: [String] = []
    @State private var foodSearch: String = ""
    @State private var foodInfo: FoodItem?
    
    var body: some View {
        VStack {
            Text("Nutrition Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            // Input for recording meals
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
            
            List(meals, id: \.self) { meal in
                Text(meal)
            }
            .listStyle(PlainListStyle())

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

            Spacer()
        }
        .padding()
    }

    private func addMeal() {
        guard !mealInput.isEmpty else { return }
        meals.append(mealInput)
        mealInput = ""
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

struct NutritionView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionView()
    }
}
