//
//  MacrosTrackingView.swift
//  myHealthArc-new-frontend
//
//  Created by Phatak, Rhea on 11/18/24.
//

import SwiftUI
import SwiftKeychainWrapper

struct MacrosTrackingView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var protein_left: Double = 0
    @State private var carbs_left: Double = 0
    @State private var fats_left: Double = 0
    @State private var protein_progress_left: Double = 0
    @State private var carbs_progress_left: Double = 0
    @State private var fats_progress_left: Double = 0
    @State private var showSheet = false

    private let dailyCaloricGoal: Double = 2000
    private let proteinPercentage: Double = 0.30
    private let fatsPercentage: Double = 0.25
    private let carbsPercentage: Double = 0.45
    
    var body: some View {
        
        NavigationView {
            VStack(spacing: 20) {
                    HStack{Image ("pills") //change to macros image
                            .resizable()
                            .scaledToFit()
                            .padding(-2)
                            .frame(width: 30)
                        Text("Macros Tracking")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                    }
                    
                    Divider()
                        .overlay(
                            (colorScheme == .dark ? Color.white : Color.gray)
                        )
                    
                
                // Manage Goals Button
                NavigationLink(destination: NutritionView()/*change to ManageGoalsView when it is created*/) {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.green)
                        Text("Manage Goals")
                            .foregroundColor(.green)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Progress Section
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        MacroProgressView(macroName: "Protein", value: protein_left, unit: "g", color: .blue, progress: protein_progress_left)
                        MacroProgressView(macroName: "Carbs", value: carbs_left, unit: "g", color: .orange, progress: carbs_progress_left)
                    }
                    
                    HStack(spacing: 20) {
                        MacroProgressView(macroName: "Fats", value: fats_left, unit: "g", color: .red, progress: fats_progress_left)
                        MacroProgressView(macroName: "Calories", value: carbs_left, unit: "kcal", color: .green, progress: carbs_progress_left)
                    }
                }
                .padding()
                
                Spacer()
                    .frame(height:30)
                
                Button(action: {showSheet = true}) {
                    Spacer()
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .frame(width: 28, height: 28)
                            .foregroundColor(.white)
                        Text("Recipe Assistant")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(10)
                    .background(Color.mhaPurple)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding(.leading, 20)
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                    .sheet(isPresented: $showSheet) {
                        ChatbotView(viewModel: ChatbotViewModel(proteinLeft: protein_left, carbsLeft: carbs_left, fatsLeft: fats_left))
                    }
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .onAppear {
                calculateMacros()
            }
        }
    }

    private func calculateMacros() {
        let expectedProtein = (dailyCaloricGoal * proteinPercentage) / 4
        let expectedFats = (dailyCaloricGoal * fatsPercentage) / 9
        let expectedCarbs = (dailyCaloricGoal * carbsPercentage) / 4
        
        fetchMealsForDay { meals in
            var totalProtein: Double = 0
            var totalFats: Double = 0
            var totalCarbs: Double = 0
            var totalCalories: Double = 0
            
            for meal in meals {
                if let proteinValue = Double(meal.totalProtein.value) {
                    totalProtein += proteinValue
                }
                if let fatsValue = Double(meal.totalFats.value) {
                    totalFats += fatsValue
                }
                if let carbsValue = Double(meal.totalCarbs.value) {
                    totalCarbs += carbsValue
                }
                if let caloriesValue = Double(meal.totalCalories.value) {
                    totalCalories += caloriesValue
                }
            }
            
            let remainingProtein = expectedProtein - totalProtein
            let remainingFats = expectedFats - totalFats
            let remainingCarbs = expectedCarbs - totalCarbs
            let remainingCalories = dailyCaloricGoal - totalCalories
            
            DispatchQueue.main.async {
                protein_left = remainingProtein
                fats_left = remainingFats
                carbs_left = remainingCarbs
                protein_progress_left = totalProtein / expectedProtein
                fats_progress_left = totalFats / expectedFats
                carbs_progress_left = totalCarbs / expectedCarbs
            }
        }
    }
    
    private func fetchMealsForDay(completion: @escaping ([Meal]) -> Void) {
        let baseURL = "http://localhost:8080/nutrition/meals"
        let dateString = ISO8601DateFormatter().string(from: Date())
        
        guard let userHash = KeychainWrapper.standard.string(forKey: "userHash"),
            let url = URL(string: "\(baseURL)?userHash=\(userHash)&date=\(dateString)") else {
            print("DEBUG - Failed to create URL with userHash or date")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("DEBUG - Error fetching meals: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("DEBUG - No data received")
                return
            }
            
            do {
                let nutritions = try JSONDecoder().decode([Nutrition].self, from: data)
                let meals = nutritions.map { nutrition in
                    Meal(
                        id: nutrition.id ?? UUID().uuidString,
                        name: nutrition.foodName,
                        totalProtein: Macro(name: "Protein", value: String(nutrition.modifiedProtein)),
                        totalCarbs: Macro(name: "Carbs", value: String(nutrition.modifiedCarbohydrates)),
                        totalFats: Macro(name: "Fats", value: String(nutrition.modifiedFats)),
                        totalCalories: Macro(name: "Calories", value: String(nutrition.modifiedCalories))
                    )
                }
                completion(meals)
            } catch {
                print("DEBUG - Decoding error: \(error)")
            }
        }.resume()
    }
}

struct MacroProgressView: View {
    var macroName: String
    var value: Double
    var unit: String
    var color: Color
    var progress: Double
    
    var body: some View {
        VStack {
            Text(macroName)
                .padding(.bottom)
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 17)
                Circle()
                    .trim(from: 0, to: progress) // Adjust for progress
                    .stroke(color, lineWidth: 17)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text(String(format: "%.1f", value))
                        .font(.headline)
                        .bold()
                    Text(unit)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 80, height: 80)
            .padding(.bottom)
        }
        .padding()
        .frame(width: 175, height: 175)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// Preview
struct MacrosTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        MacrosTrackingView()
    }
}