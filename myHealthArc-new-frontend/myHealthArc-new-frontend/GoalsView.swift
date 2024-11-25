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
                    .overlay(Color.gray.opacity(0.6))
                    .frame(height: 0)

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
                                    title: "Calories Consumed",
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
                    }

                    // Save Button
                    Button(action: saveGoals) {
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
            .onAppear {
                goalsManager.fetchGoals(from: baseURL, userHash: userId)
            }
        }
    }

    private func saveGoals() {
        goalsManager.saveGoals(to: baseURL, userHash: userId)
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
