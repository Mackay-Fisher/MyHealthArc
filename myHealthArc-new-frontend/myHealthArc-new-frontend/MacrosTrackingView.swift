//
//  MacrosTrackingView.swift
//  myHealthArc-new-frontend
//
//  Created by Phatak, Rhea on 11/18/24.
//
import SwiftUI
import SwiftKeychainWrapper

struct BodyDataModel: Codable {
    let userHash: String
    let height: Double
    let weight: Double
    let age: Int
    let gender: String
    let bmi: Double?
}

struct MacrosTrackingView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var protein_left: Double = 0
    @State private var carbs_left: Double = 0
    @State private var fats_left: Double = 0
    @State private var calories_left: Double = 0
    @State private var protein_progress_left: Double = 0
    @State private var carbs_progress_left: Double = 0
    @State private var fats_progress_left: Double = 0
    @State private var calories_progress_left: Double = 0
    @State private var showSheet = false

    @State private var dailyCaloricGoal: Double = 2000
    private let proteinPercentage: Double = 0.30
    private let fatsPercentage: Double = 0.25
    private let carbsPercentage: Double = 0.45

    @StateObject private var goalsManager = GoalsManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Image("macros")
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

                NavigationLink(destination: GoalsView()) {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.mhaGreen)
                        Text("Manage Goals")
                            .foregroundColor(.mhaGreen)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        MacroProgressView(macroName: "Protein", value: protein_left, unit: "g", color: .mhaBlue, progress: protein_progress_left)
                        MacroProgressView(macroName: "Carbs", value: carbs_left, unit: "g", color: .mhaOrange, progress: carbs_progress_left)
                    }

                    HStack(spacing: 20) {
                        MacroProgressView(macroName: "Fats", value: fats_left, unit: "g", color: .mhaSalmon, progress: fats_progress_left)
                        MacroProgressView(macroName: "Calories", value: calories_left, unit: "kcal", color: .mhaGreen, progress: calories_progress_left)
                    }
                }
                .padding()

                Spacer()
                    .frame(height: 30)

                Button(action: { showSheet = true }) {
                    Spacer()
                    HStack {
                        Image("ai")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 55, height: 55)
                    }
                    .padding(20)
                    .sheet(isPresented: $showSheet) {
                        ChatbotView(viewModel: ChatbotViewModel(proteinLeft: protein_left, carbsLeft: carbs_left, fatsLeft: fats_left))
                    }
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .onAppear {
                loadData()
            }
        }
    }
    
    private func loadData() {
        Task {
            await fetchGoalsAndBodyData()
            // Force an immediate fetch of meals after goals
            fetchMealsForDay { meals in
                var totalProtein: Double = 0
                var totalFats: Double = 0
                var totalCarbs: Double = 0
                var totalCalories: Double = 0

                for meal in meals {
                    totalProtein += Double(meal.totalProtein.value) ?? 0
                    totalFats += Double(meal.totalFats.value) ?? 0
                    totalCarbs += Double(meal.totalCarbs.value) ?? 0
                    totalCalories += Double(meal.totalCalories.value) ?? 0
                }

                DispatchQueue.main.async {
                    if let proteinGoal = self.goalsManager.goals["protein-goal"],
                       let carbsGoal = self.goalsManager.goals["carbs-goal"],
                       let fatsGoal = self.goalsManager.goals["fat-goal"] {
                        
                        protein_left = Double(proteinGoal) - totalProtein
                        fats_left = Double(fatsGoal) - totalFats
                        carbs_left = Double(carbsGoal) - totalCarbs
                        calories_left = dailyCaloricGoal - totalCalories

                        protein_progress_left = totalProtein / Double(proteinGoal)
                        fats_progress_left = totalFats / Double(fatsGoal)
                        carbs_progress_left = totalCarbs / Double(carbsGoal)
                        calories_progress_left = totalCalories / dailyCaloricGoal
                    }
                }
            }
        }
    }

    private func fetchGoalsAndBodyData() async {
        let userId = KeychainWrapper.standard.string(forKey: "userHash") ?? ""
        do {
            try await goalsManager.fetchGoals(from: "\(AppConfig.baseURL)/goals", userHash: userId)

            if let proteinGoal = goalsManager.goals["protein-goal"],
               let carbsGoal = goalsManager.goals["carbs-goal"],
               let fatsGoal = goalsManager.goals["fat-goal"],
               let caloriesGoal = goalsManager.goals["calories-consumed"] {
                dailyCaloricGoal = Double(caloriesGoal)
            } else {
                print("DEBUG - Missing goals in response, using defaults")
            }
        } catch {
            print("DEBUG - Error fetching goals: \(error.localizedDescription)")
        }
    }

    private func fetchMealsForDay(completion: @escaping ([Meal]) -> Void) {
        let baseURL = "\(AppConfig.baseURL)/nutrition/meals"
        let dateString = ISO8601DateFormatter().string(from: Date())

        guard let userHash = KeychainWrapper.standard.string(forKey: "userHash"),
              let url = URL(string: "\(baseURL)?userHash=\(userHash)&date=\(dateString)") else {
            print("DEBUG - Failed to create URL with userHash or date")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, _, error in
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
                    .stroke(Color(.systemGray5), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, lineWidth: 8)
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
            .frame(width: 90, height: 90)
            .padding(.bottom)
        }
        .padding()
        .frame(width: 175, height: 175)
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

struct MacrosTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        MacrosTrackingView()
    }
}
