//
//  NutritionWidgetView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/23/24.
//


import SwiftUI

struct NutritionWidgetView: View {
    @State private var foodSearch: String = ""
    @State private var foodInfo: String = ""
    @State private var showFoodInfo: Bool = false

    var body: some View {
        NavigationLink(destination: NutritionView()) {
            VStack {
                Text("Nutrition Search")
                    .font(.headline)
                    .padding(.top)
                Divider()

                // Food search input with system icon button
                HStack {
                    TextField("Search for food", text: $foodSearch, onCommit: {
                        fetchFoodInfo()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: fetchFoodInfo) {
                        Image(systemName: "magnifyingglass") // Search icon
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.mhaPurple)
                            .clipShape(Circle())
                    }
                }
                .padding()

                // Display food info
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
                        .frame(maxWidth: .infinity, alignment: .center) // Center the button
                    }
                    .padding()
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 0.5)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func fetchFoodInfo() {
        // Simulate API call with mock data
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

    private func clearSearch() {
        foodSearch = ""
        foodInfo = ""
        showFoodInfo = false
    }
}

struct NutritionWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionWidgetView()
    }
}
