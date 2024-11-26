//
//  GoalsView 2.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/21/24.
//
import SwiftUI
import SwiftKeychainWrapper

struct GoalsView: View {
    @StateObject private var goalsManager = GoalsManager()
    private let baseURL = "http://209.38.153.40:8080/goals"
    private let userId = KeychainWrapper.standard.string(forKey: "userHash") ?? ""
    @State private var showingSaveConfirmation = false
    @State private var isSaving = false
    @State private var saveError: String?

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
                }

                Divider()

                // Main Content
                if goalsManager.isLoading {
                    ProgressView("Loading Goals...")
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 30) {
                            // MARK: - Fitness Goals Section
                            SectionHeaderView(title: "Manage Fitness Goals")
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                GoalAdjusterView(
                                    title: "Step Count",
                                    value: Binding(
                                        get: { goalsManager.goals["step-count"] ?? 0 },
                                        set: { goalsManager.goals["step-count"] = $0 }
                                    ),
                                    unit: "steps/day",
                                    step: 1000
                                )
                                GoalAdjusterView(
                                    title: "Exercise Minutes",
                                    value: Binding(
                                        get: { goalsManager.goals["exercise-minutes"] ?? 0 },
                                        set: { goalsManager.goals["exercise-minutes"] = $0 }
                                    ),
                                    unit: "min/day",
                                    step: 5
                                )
                                GoalAdjusterView(
                                    title: "Calories Burned",
                                    value: Binding(
                                        get: { goalsManager.goals["calories-burned"] ?? 0 },
                                        set: { goalsManager.goals["calories-burned"] = $0 }
                                    ),
                                    unit: "kcal/day",
                                    step: 50
                                )
                                GoalAdjusterView(
                                    title: "Time Asleep",
                                    value: Binding(
                                        get: { goalsManager.goals["time-asleep"] ?? 0 },
                                        set: { goalsManager.goals["time-asleep"] = $0 }
                                    ),
                                    unit: "hrs/day",
                                    step: 1
                                )
                                GoalAdjusterView(
                                    title: "Water Intake",
                                    value: Binding(
                                        get: { goalsManager.goals["water-intake"] ?? 0 },
                                        set: { goalsManager.goals["water-intake"] = $0 }
                                    ),
                                    unit: "glasses/day",
                                    step: 1
                                )
                                GoalAdjusterView(
                                    title: "Workouts/Week",
                                    value: Binding(
                                        get: { goalsManager.goals["workouts-per-week"] ?? 0 },
                                        set: { goalsManager.goals["workouts-per-week"] = $0 }
                                    ),
                                    unit: "workouts/week",
                                    step: 1
                                )
                                GoalAdjusterView(
                                    title: "Elevation Gained",
                                    value: Binding(
                                        get: { goalsManager.goals["elevation-gained"] ?? 0 },
                                        set: { goalsManager.goals["elevation-gained"] = $0 }
                                    ),
                                    unit: "feet/day",
                                    step: 100
                                )
                                GoalAdjusterView(
                                    title: "Distance Traveled",
                                    value: Binding(
                                        get: { goalsManager.goals["distance-traveled"] ?? 0 },
                                        set: { goalsManager.goals["distance-traveled"] = $0 }
                                    ),
                                    unit: "miles/day",
                                    step: 1
                                )
                            }

                            Divider()
                                .padding(.horizontal)

                            // MARK: - Nutrition Goals Section
                            SectionHeaderView(title: "Manage Nutrition Goals")
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                GoalAdjusterView(
                                    title: "Protein",
                                    value: Binding(
                                        get: { goalsManager.goals["protein-goal"] ?? 0 },
                                        set: { goalsManager.goals["protein-goal"] = $0 }
                                    ),
                                    unit: "g/day",
                                    step: 5
                                )
                                GoalAdjusterView(
                                    title: "Carbs",
                                    value: Binding(
                                        get: { goalsManager.goals["carbs-goal"] ?? 0 },
                                        set: { goalsManager.goals["carbs-goal"] = $0 }
                                    ),
                                    unit: "g/day",
                                    step: 25
                                )
                                GoalAdjusterView(
                                    title: "Fat",
                                    value: Binding(
                                        get: { goalsManager.goals["fat-goal"] ?? 0 },
                                        set: { goalsManager.goals["fat-goal"] = $0 }
                                    ),
                                    unit: "g/day",
                                    step: 5
                                )
                                GoalAdjusterView(
                                    title: "Calorie Intake",
                                    value: Binding(
                                        get: { goalsManager.goals["calories-consumed"] ?? 0 },
                                        set: { goalsManager.goals["calories-consumed"] = $0 }
                                    ),
                                    unit: "kcal/day",
                                    step: 100
                                )
                            }
                        }
                        .padding()
                        
                        // Save Button
                        Button(action: saveGoals) {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .padding(.trailing, 5)
                                }
                                Text(isSaving ? "Saving..." : "Save Goals")
                            }
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: 200)
                            .background(isSaving ? Color.gray : Color.mhaGreen)
                            .foregroundColor(.white)
                            .cornerRadius(50)
                        }
                        .disabled(isSaving)
                        .padding()
                    }
                }
            }
            .onAppear {
                Task{
                    try await goalsManager.fetchGoals(from: baseURL, userHash: userId)
                }
                
            }
            .alert("Success!", isPresented: $showingSaveConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your goals have been successfully updated.")
            }
            .alert("Error Saving Goals", isPresented: .init(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )) {
                Button("OK", role: .cancel) { saveError = nil }
            } message: {
                if let error = saveError {
                    Text(error)
                }
            }
        }
    }

    private func saveGoals() {
        isSaving = true
        
        // Create URL request
        guard let requestURL = URL(string: "\(baseURL)/update") else {
            saveError = "Invalid URL"
            isSaving = false
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = ["userId": userId, "goals": goalsManager.goals] as [String: Any]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            saveError = "Failed to prepare data"
            isSaving = false
            return
        }
        
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isSaving = false
                
                if let error = error {
                    saveError = "Failed to save: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    saveError = "Invalid server response"
                    return
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    showingSaveConfirmation = true
                case 400:
                    saveError = "Invalid data submitted"
                case 401:
                    saveError = "Unauthorized access"
                case 500:
                    saveError = "Server error. Please try again later"
                default:
                    saveError = "Failed to save goals (Error: \(httpResponse.statusCode))"
                }
            }
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
    }
}

// MARK: - Goal Adjuster View
struct GoalAdjusterView: View {
    let title: String
    @Binding var value: Int
    let unit: String
    let step: Int
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.headline)
            HStack {
                Button(action: {
                    if value > 0 { value -= step }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .font(.title2)
                }

                Text("\(value)")
                    .font(.title2)
                    .frame(width: 80, alignment: .center)

                Button(action: {
                    value += step
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .font(.title2)
                }
            }
            Text(unit)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView()
    }
}
