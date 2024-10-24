//
//  NutritionView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/23/24.
//


import SwiftUI
import SwiftUI

struct Meal {
    let name: String
    let totalNutrition: String
}

struct NutritionView: View {
    @State private var mealInput: String = ""
    @State private var meals: [Meal] = []
    @State private var foodSearch: String = ""
    @State private var foodInfo: String = ""
    @State private var showFoodInfo: Bool = false
    @State private var totalNutrition: String = ""
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            HStack{Image ("carrot")
                    .resizable()
                    .scaledToFit()
                    .padding(-2)
                    .frame(width: 30)
                Text("Nutrition Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
            }
            
            Divider()
                .overlay(
                    (colorScheme == .dark ? Color.white : Color.gray)
                )
            Spacer()
                .frame(height:20)
            
            // Meal Input Section
            HStack {
                TextField("Enter meal (comma-separated)", text: $mealInput)
                //.padding(.leading, 2)
                    .padding(5)
                    .background(colorScheme == .dark ? Color.mhaGray : Color.white)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(colorScheme == .dark ? Color.white : Color.gray, lineWidth: 0.5)
                    )
                //.frame(width: 250, height: 150, alignment:.center)
                
                Button("Add Meal") {
                    addMeal()
                }
                .padding()
                .frame(width: 120, height: 40)
                .background(Color.mhaGreen)
                .cornerRadius(50)
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            }
            //TODO: figure out why spacing is so messed up
            Spacer()
                .frame(height:20)
            
            if !meals.isEmpty {
                            Text("Your Meals")
                                .font(.title3)
                                .padding(.top)
                        }
            List(meals, id: \.name) { meal in
                VStack(alignment: .leading) {
                    Text(meal.name)
                        .font(.headline)
                        .padding(.bottom, 2)
                    
                    Text(meal.totalNutrition)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                }
            }
            .listStyle(PlainListStyle())
            .padding(.bottom)
            .padding(.leading, -15)
            
            Spacer()
        

            // Food Search Section
            HStack {
                
                TextField("Search for food", text: $foodSearch, onCommit: {
                    fetchFoodInfo()
                })
                .padding(5)
                .background(colorScheme == .dark ? Color.mhaGray : Color.white)
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorScheme == .dark ? Color.white : Color.gray, lineWidth: 0.5)
                )
                //.frame(width: 250, height: 150, alignment:.center)


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

            // Split the meal input into individual food items
            let foodItems = mealInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            let mealName = mealInput  // Keep the original meal input
            mealInput = ""  // Clear the input

            // Fetch nutrition info for the food items
            fetchNutritionInfo(for: foodItems, mealName: mealName)
        }


    // Fetch Nutrition Info for the Meal
        private func fetchNutritionInfo(for foodItems: [String], mealName: String) {
            guard !foodItems.isEmpty else { return }

            // Prepare the URL with query parameters
            let baseURL = "http://localhost:8080/nutrition/info"
            let query = foodItems.joined(separator: ",").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            guard let url = URL(string: "\(baseURL)?query=\(query)") else {
                print("Invalid URL")
                return
            }

            // Create the request
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            // Perform the API call
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        totalNutrition = "Error: \(error.localizedDescription)"
                        showFoodInfo = true
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        totalNutrition = "No data received."
                        showFoodInfo = true
                    }
                    return
                }

                // Decode the response and combine nutrient info
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Double]] {
                        var totalProtein = 0.0
                        var totalCarbs = 0.0
                        var totalFats = 0.0
                        var totalCalories = 0

                        // Combine the nutrient values
                        for (_, nutrients) in json {
                            totalProtein += nutrients["protein"] ?? 0
                            totalCarbs += nutrients["carbohydrates"] ?? 0
                            totalFats += nutrients["fats"] ?? 0
                            totalCalories += Int(nutrients["calories"] ?? 0)
                        }

                        // Format the total nutrient information
                        DispatchQueue.main.async {
                            totalNutrition = """
                            Protein: \(totalProtein)g, \
                            Carbs: \(totalCarbs)g, \
                            Fats: \(totalFats)g, \
                            Calories: \(totalCalories)
                            """
                            // Add the meal and its nutrition info to the list
                            meals.append(Meal(name: mealName, totalNutrition: totalNutrition))
                            showFoodInfo = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            totalNutrition = "Failed to parse response."
                            showFoodInfo = true
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        totalNutrition = "Decoding error: \(error.localizedDescription)"
                        showFoodInfo = true
                    }
                }
            }.resume()
        }

    // Mock API Call to Fetch Food Info
    private func fetchFoodInfo() {
//        let mockData: [String: String] = [
//            "apple": "Apple - Calories: 95, Carbs: 25g, Protein: 0.5g, Fats: 0.3g",
//            "banana": "Banana - Calories: 105, Carbs: 27g, Protein: 1.3g, Fats: 0.4g"
//        ]
//
//        if let info = mockData[foodSearch.lowercased()] {
//            foodInfo = info
//            showFoodInfo = true
//        } else {
//            foodInfo = "No information found."
//            showFoodInfo = true
//        }
        guard !foodSearch.isEmpty else { return }

                // Prepare the URL with query parameters
                let baseURL = "http://localhost:8080/nutrition/info"
                let query = foodSearch.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                guard let url = URL(string: "\(baseURL)?query=\(query)") else {
                    print("Invalid URL")
                    return
                }

                // Create the request
                var request = URLRequest(url: url)
                request.httpMethod = "GET"

                // Perform the API call
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            foodInfo = "Error: \(error.localizedDescription)"
                            showFoodInfo = true
                        }
                        return
                    }

                    guard let data = data else {
                        DispatchQueue.main.async {
                            foodInfo = "No data received."
                            showFoodInfo = true
                        }
                        return
                    }

                    // Decode the response
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Double]] {
                            if let firstFoodItem = json.first {
                                let foodItem = firstFoodItem.key
                                let nutrients = firstFoodItem.value
                                foodInfo = """
                                \(foodItem.capitalized) - Protein: \(nutrients["protein"] ?? 0)g, \
                                Carbs: \(nutrients["carbohydrates"] ?? 0)g, \
                                Fats: \(nutrients["fats"] ?? 0)g, \
                                Calories: \(nutrients["calories"] ?? 0)
                                """
                            } else {
                                foodInfo = "No information found."
                            }
                        } else {
                            foodInfo = "Failed to parse response."
                        }
                    } catch {
                        foodInfo = "Decoding error: \(error.localizedDescription)"
                    }

                    // Update UI on the main thread
                    DispatchQueue.main.async {
                        showFoodInfo = true
                    }
                }.resume()
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
