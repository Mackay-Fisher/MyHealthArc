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
                TextField("Enter meal", text: $mealInput)
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
                .background(Color.mhaGreen)
                .cornerRadius(50)
                .foregroundColor(.white)
            }
            //TODO: figure out why spacing is so messed up
            Spacer()
                .frame(height:10)

            
            Text("Your Meals")
                .font(.title3)
                .padding()
            // List of Recorded Meals
            List(meals, id: \.self) { meal in
                Text(meal)
            }
            .listStyle(PlainListStyle())
            .padding(.bottom)
            .padding(.leading, -15)


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
