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
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationLink(destination: NutritionView()) {
            VStack {
                HStack {
                    Spacer()
                    HStack {
                        Image("carrot")
                            .resizable()
                            .scaledToFit()
                            .padding(-1)
                            .frame(width: 30)
                        
                        Spacer()
                            .frame(width: 15)
                        
                        Text("Nutrition Search")
                            .font(.headline)
                            .padding(.top)
                            .frame(alignment: .leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .padding(.top)
                        .foregroundColor(colorScheme == .dark ? Color.lightbackground : Color.gray)
                }
                Divider()

                // Food search input with system icon button
                HStack {
                    TextField("Search food nutrition info", text: $foodSearch)
                    .padding(5)
                    .background(colorScheme == .dark ? Color.mhaGray : Color.white)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(colorScheme == .dark ? Color.white : Color.gray, lineWidth: 0.5)
                    )

                    Button(action: fetchFoodInfo) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.mhaGreen)
                            .clipShape(Circle())
                    }
                }
                .padding()

                // Display food info
                if showFoodInfo {
                    VStack(alignment: .leading, spacing: 15) {
                        // Food Name (first part before the first " - ")
                        let items = foodInfo.split(separator: " - ", maxSplits: 1)
                        if items.count == 2 {
                            Text(String(items[0]).capitalized)
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            // Nutrients info
                            let nutrients = String(items[1]).components(separatedBy: ", ")
                            ForEach(nutrients, id: \.self) { nutrient in
                                let parts = nutrient.split(separator: ":")
                                if parts.count == 2 {
                                    let name = String(parts[0]) + ":"
                                    let values = String(parts[1]).trimmingCharacters(in: .whitespaces)
                                    
                                    HStack(spacing: 10) {
                                        Circle()
                                            .fill(colorForMacro(name))
                                            .frame(width: 8, height: 8)
                                        
                                        Text(name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .frame(width: 80, alignment: .leading)
                                        
                                        Text(values)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        if name == "Calories:" {
                                            Text("kcal")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        } else {
                                            Text("g")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            
                            Button(action: clearSearch) {
                                Text("Clear")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(Color.mhaSalmon)
                                    .cornerRadius(20)
                            }
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding()
                }
            }
            .frame(width: 320)
            .padding()
            .background(colorScheme == .dark ? Color.mhaGray : Color.white)
            .cornerRadius(30)
            .shadow(radius: 0.2)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func colorForMacro(_ macroName: String) -> Color {
        switch macroName {
        case "Protein:":
            return Color.mhaBlue
        case "Carbs:":
            return Color.mhaOrange
        case "Fats:":
            return Color.mhaSalmon
        case "Calories:":
            return Color.mhaGreen
        default:
            return Color.gray.opacity(0.8)
        }
    }

    private func fetchFoodInfo() {
        guard !foodSearch.isEmpty else { return }

        let baseURL = "\(AppConfig.baseURL)/nutrition/info"
        let query = foodSearch.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(baseURL)?query=\(query)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

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

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Double]] {
                    if let firstFoodItem = json.first {
                        let foodItem = firstFoodItem.key
                        let nutrients = firstFoodItem.value
                        foodInfo = """
                        \(foodItem.capitalized) - Protein: \(nutrients["proteinMinimum"] ?? 0)g - \(nutrients["proteinMaximum"] ?? 0), \
                        Carbs: \(nutrients["carbohydratesMinimum"] ?? 0) - \(nutrients["carbohydratesMaximum"] ?? 0), \
                        Fats: \(nutrients["fatsMinimum"] ?? 0) - \(nutrients["fatsMaximum"] ?? 0), \
                        Calories: \(nutrients["caloriesMinimum"] ?? 0) - \(nutrients["caloriesMaximum"] ?? 0)
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

            DispatchQueue.main.async {
                showFoodInfo = true
            }
        }.resume()
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
