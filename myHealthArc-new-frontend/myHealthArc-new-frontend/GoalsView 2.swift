//
//  GoalsView 2.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/21/24.
//
import SwiftUI

struct GoalsView: View {
    @State private var stepCount = 0
    @State private var exerciseMinutes = 0
    @State private var caloriesBurned = 0
    @State private var timeAsleep = 0
    @State private var waterIntake = 0
    @State private var workoutsPerWeek = 0
    @State private var proteinGoal = 0
    @State private var carbsGoal = 0
    @State private var fatGoal = 0
    @State private var caloriesConsumed = 0

    @State private var isLoading = true

    private let baseURL = "https://e0dc-198-217-29-75.ngrok-free.app/goals"
    private let userId = "dummy_user_id"

    var body: some View {
        NavigationView {
            VStack {
                // Header
                HStack {
                    Image("goals")
                        .resizable()
                        .scaledToFit()
                        .padding(-2)
                        .frame(width: 30)
                    Text("Goals")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                }

                Divider()
                    .overlay(Color.gray.opacity(0.6))
                    .frame(height: 2)

                // Main Content
                if isLoading {
                    ProgressView("Loading Goals...")
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 30) {
                            // MARK: - Fitness Goals Section
                            SectionHeaderView(title: "Manage Fitness Goals")
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                GoalAdjusterView(title: "Step Count", value: $stepCount, unit: "steps/day", step: 1000)
                                GoalAdjusterView(title: "Exercise Minutes", value: $exerciseMinutes, unit: "min/day", step: 5)
                                GoalAdjusterView(title: "Calories Burned", value: $caloriesBurned, unit: "kcal/day", step: 50)
                                GoalAdjusterView(title: "Time Asleep", value: $timeAsleep, unit: "hrs/day", step: 1)
                                GoalAdjusterView(title: "Water Intake", value: $waterIntake, unit: "glasses/day", step: 1)
                                GoalAdjusterView(title: "Workouts", value: $workoutsPerWeek, unit: "workouts/week", step: 1)
                            }

                            Divider()
                                .padding(.horizontal)

                            // MARK: - Nutrition Goals Section
                            SectionHeaderView(title: "Manage Nutrition Goals")
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                GoalAdjusterView(title: "Protein", value: $proteinGoal, unit: "g/day", step: 5)
                                GoalAdjusterView(title: "Carbs", value: $carbsGoal, unit: "g/day", step: 25)
                                GoalAdjusterView(title: "Fat", value: $fatGoal, unit: "g/day", step: 5)
                                GoalAdjusterView(title: "Calories Consumed", value: $caloriesConsumed, unit: "kcal/day", step: 100)
                            }
                        }
                        .padding()
                    }

                    // Save Button
                    Button(action: saveGoalsToAPI) {
                        Text("Save Goals")
                            .font(.title2)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .onAppear(perform: fetchGoalsFromAPI)
        }
    }

    // MARK: - Fetch Goals from API
    private func fetchGoalsFromAPI() {
        isLoading = true
        guard let url = URL(string: "\(baseURL)/fetch?userId=\(userId)") else {
            print("Invalid URL")
            isLoading = false
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            isLoading = false
            guard let data = data, error == nil else {
                print("Error fetching goals: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                if let goals = try JSONSerialization.jsonObject(with: data) as? [String: Int] {
                    DispatchQueue.main.async {
                        stepCount = goals["stepCount"] ?? 0
                        exerciseMinutes = goals["exerciseMinutes"] ?? 0
                        caloriesBurned = goals["caloriesBurned"] ?? 0
                        timeAsleep = goals["timeAsleep"] ?? 0
                        waterIntake = goals["waterIntake"] ?? 0
                        workoutsPerWeek = goals["workoutsPerWeek"] ?? 0
                        proteinGoal = goals["proteinGoal"] ?? 0
                        carbsGoal = goals["carbsGoal"] ?? 0
                        fatGoal = goals["fatGoal"] ?? 0
                        caloriesConsumed = goals["caloriesConsumed"] ?? 0
                    }
                }
            } catch {
                print("Error parsing goals JSON: \(error)")
            }
        }.resume()
    }

    // MARK: - Save Goals to API
    private func saveGoalsToAPI() {
        guard let url = URL(string: "\(baseURL)/update") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let goals: [String: Int] = [
            "stepCount": stepCount,
            "exerciseMinutes": exerciseMinutes,
            "caloriesBurned": caloriesBurned,
            "timeAsleep": timeAsleep,
            "waterIntake": waterIntake,
            "workoutsPerWeek": workoutsPerWeek,
            "proteinGoal": proteinGoal,
            "carbsGoal": carbsGoal,
            "fatGoal": fatGoal,
            "caloriesConsumed": caloriesConsumed
        ]

        let requestBody = ["userId": userId, "goals": goals] as [String: Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error saving goals: \(error)")
                return
            }
            print("Goals successfully saved!")
        }.resume()
    }
}

// MARK: - Section Header View
struct SectionHeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding()
    }
}

// MARK: - Goal Adjuster View
struct GoalAdjusterView: View {
    let title: String
    @Binding var value: Int
    let unit: String
    let step: Int

    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.headline)
            HStack {
                Button(action: {
                    if value > 0 { value -= step }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.black)
                        .font(.title2)
                }

                Text("\(value)")
                    .font(.title2)
                    .frame(width: 80, alignment: .center)

                Button(action: {
                    value += step
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.black)
                        .font(.title2)
                }
            }
            Text(unit)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Preview
struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView()
    }
}
