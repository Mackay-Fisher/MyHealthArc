//
//  GoalsView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 11/19/24.
//

//
//  GoalsPage.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 11/19/24.
//

import SwiftUI

struct FitnessGoal: Identifiable {
    let id = UUID()
    let name: String
    let value: Int
    let color: Color
}

class FitnessGoalsViewModel: ObservableObject {
    @Published var stepCount = 10000
    @Published var exerciseMinutes = 30
    @Published var caloriesBurned = 500
    @Published var timeAsleep = 8
    @Published var waterIntake = 8
    @Published var workoutsPerWeek = 6
    @Published var proteinGoal = 60
    @Published var carbsGoal = 300
    @Published var fatGoal = 50
    @Published var caloriesConsumed = 2200
    
    let streakCount = 14
}

struct GoalsView: View {
    @StateObject private var viewModel = FitnessGoalsViewModel()
    
    private let streaks: [FitnessGoal] = [
        FitnessGoal(name: "Steps", value: 14, color: .blue),
        FitnessGoal(name: "Exercise", value: 14, color: .purple),
        FitnessGoal(name: "Cal Burned", value: 14, color: .pink),
        FitnessGoal(name: "Sleep", value: 14, color: .teal),
        FitnessGoal(name: "Water", value: 14, color: .blue),
        FitnessGoal(name: "Workouts", value: 14, color: .green),
        FitnessGoal(name: "Nutrition", value: 14, color: .orange)
    ]
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack {
                HStack{Image ("goals")
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
                    .overlay(
                        (colorScheme == .dark ? Color.white : Color.gray)
                    )
                //Spacer()
                .frame(height:20)
                ScrollView {
                    VStack(spacing: 30) {
                        // Streaks Section
                        VStack(spacing: 15) {
                            Text("Streaks")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 20) {
                                ForEach(streaks) { streak in
                                    VStack {
                                        Text(streak.name)
                                            .font(.caption)
                                        ZStack {
                                            Circle()
                                                .fill(streak.color.opacity(0.2))
                                                .frame(width: 60, height: 60)
                                            Text("\(streak.value)")
                                                .foregroundColor(streak.color)
                                                .fontWeight(.bold)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Fitness Goals Section
                        VStack(spacing: 15) {
                            Text("Manage Fitness Goals")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                GoalAdjusterView(title: "Step Count",
                                                 value: $viewModel.stepCount,
                                                 unit: "steps/day",
                                                 step: 1000)
                                
                                GoalAdjusterView(title: "Exercise Minutes",
                                                 value: $viewModel.exerciseMinutes,
                                                 unit: "min/day",
                                                 step: 5)
                                
                                GoalAdjusterView(title: "Calories Burned",
                                                 value: $viewModel.caloriesBurned,
                                                 unit: "kcal/day",
                                                 step: 50)
                                
                                GoalAdjusterView(title: "Time Asleep",
                                                 value: $viewModel.timeAsleep,
                                                 unit: "hr/day",
                                                 step: 1)
                                
                                GoalAdjusterView(title: "Water Intake",
                                                 value: $viewModel.waterIntake,
                                                 unit: "glasses/day",
                                                 step: 1)
                                
                                GoalAdjusterView(title: "Workouts",
                                                 value: $viewModel.workoutsPerWeek,
                                                 unit: "workouts/week",
                                                 step: 1)
                            }
                        }
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Nutrition Goals Section
                        VStack(spacing: 15) {
                            Text("Manage Nutrition Goals")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                GoalAdjusterView(title: "Protein",
                                                 value: $viewModel.proteinGoal,
                                                 unit: "g/day",
                                                 step: 5)
                                
                                GoalAdjusterView(title: "Carbs",
                                                 value: $viewModel.carbsGoal,
                                                 unit: "g/day",
                                                 step: 25)
                                
                                GoalAdjusterView(title: "Fat",
                                                 value: $viewModel.fatGoal,
                                                 unit: "g/day",
                                                 step: 5)
                                
                                GoalAdjusterView(title: "Calories Consumed",
                                                 value: $viewModel.caloriesConsumed,
                                                 unit: "kcal/day",
                                                 step: 100)
                            }
                        }
                    }
                    .padding()}
            }
        }
    }
}

struct GoalAdjusterView: View {
    let title: String
    @Binding var value: Int
    let unit: String
    let step: Int
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.subheadline)
            
            HStack {
                Button(action: { value -= step }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.blue)
                }
                
                Text("\(value)")
                    .frame(minWidth: 60)
                    .multilineTextAlignment(.center)
                
                Button(action: { value += step }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
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

#Preview {
    GoalsView()
}
