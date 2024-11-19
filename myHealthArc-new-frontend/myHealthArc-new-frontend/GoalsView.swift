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
    
    // Streak variables
    @Published var stepsStreak = 14
    @Published var exerciseStreak = 14
    @Published var calBurnedStreak = 14
    @Published var sleepStreak = 14
    @Published var waterStreak = 14
    @Published var workoutsStreak = 14
    @Published var nutritionStreak = 14
    
    // Computed property to create streak array with consistent colors
    var streaks: [FitnessGoal] {
        [
            FitnessGoal(name: "Steps", value: stepsStreak, color: GoalColors.steps),
            FitnessGoal(name: "Exercise", value: exerciseStreak, color: GoalColors.exercise),
            FitnessGoal(name: "Cal Burned", value: calBurnedStreak, color: GoalColors.calories),
            FitnessGoal(name: "Sleep", value: sleepStreak, color: GoalColors.sleep),
            FitnessGoal(name: "Water", value: waterStreak, color: GoalColors.water),
            FitnessGoal(name: "Workouts", value: workoutsStreak, color: GoalColors.workouts),
            FitnessGoal(name: "Nutrition", value: nutritionStreak, color: GoalColors.nutrition)
        ]
    }
    
    // Functions to update streaks
        func updateStepsStreak(stepsCompleted: Int) {
            if stepsCompleted >= stepCount {
                stepsStreak += 1
            } else {
                stepsStreak = 0
            }
        }
        
        func updateExerciseStreak(minutesCompleted: Int) {
            if minutesCompleted >= exerciseMinutes {
                exerciseStreak += 1
            } else {
                exerciseStreak = 0
            }
        }
        
        func updateCalorieStreak(caloriesBurnedToday: Int) {
            if caloriesBurnedToday >= caloriesBurned {
                calBurnedStreak += 1
            } else {
                calBurnedStreak = 0
            }
        }
        
        func updateSleepStreak(hoursSlept: Int) {
            if hoursSlept >= timeAsleep {
                sleepStreak += 1
            } else {
                sleepStreak = 0
            }
        }
        
        func updateWaterStreak(glassesConsumed: Int) {
            if glassesConsumed >= waterIntake {
                waterStreak += 1
            } else {
                waterStreak = 0
            }
        }
        
        func updateWorkoutStreak(workoutsCompleted: Int) {
            if workoutsCompleted >= workoutsPerWeek {
                workoutsStreak += 1
            } else {
                workoutsStreak = 0
            }
        }
        
        func updateNutritionStreak(meetsNutritionGoals: Bool) {
            if meetsNutritionGoals { //supposed to check all the shit
                nutritionStreak += 1
            } else {
                nutritionStreak = 0
            }
        }
        
        // Function to check if nutrition goals are met (cuz its one streak)
        func checkNutritionGoals(protein: Int, carbs: Int, fat: Int, calories: Int) -> Bool {
            let proteinMet = protein >= proteinGoal
            let carbsMet = carbs >= carbsGoal
            let fatMet = fat >= fatGoal
            let caloriesMet = calories >= caloriesConsumed // could be less than if its a limit??????? i dont fucking know
            
            return proteinMet && carbsMet && fatMet && caloriesMet
        }
}

//TODO: change later when merging everyting

struct GoalColors {
    static let steps = Color.blue
    static let exercise = Color.purple
    static let calories = Color.pink
    static let sleep = Color.teal
    static let water = Color.blue
    static let workouts = Color.green
    static let nutrition = Color.orange
}

struct GoalsView: View {
    @StateObject private var viewModel = FitnessGoalsViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack {
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
                    .overlay(colorScheme == .dark ? Color.white : Color.gray)
                    .frame(height: 20)
                
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
                                ForEach(viewModel.streaks) { streak in
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
                        //NOTE: the step is how much its incrementing by cuz in most cases it shouldnt be 1
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
                        //TODO: these need to pull from the stuff james calculates so the values need to be updated accordingly
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
                    .padding()
                }
            }
        }
    }
}


struct GoalAdjusterView: View {
    let title: String
    @Binding var value: Int
    let unit: String
    let step: Int
    
    // Get the appropriate color based on the goal title - probably need to change these colors later also smhhhhhh
    private var buttonColor: Color {
        switch title {
        case "Step Count":
            return .blue
        case "Exercise Minutes":
            return .purple
        case "Calories Burned":
            return .pink
        case "Time Asleep":
            return .teal
        case "Water Intake":
            return .blue
        case "Workouts":
            return .green
        case "Protein":
            return .blue
        case "Carbs":
            return .orange
        case "Fat":
            return .red
        case "Calories Consumed":
            return .green
        default:
            return .blue
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.subheadline)
            Divider()
            HStack {
                Button(action: { value -= step }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(buttonColor)
                }
                
                Text("\(value)")
                    .frame(minWidth: 60)
                    .multilineTextAlignment(.center)
                
                Button(action: { value += step }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(buttonColor)
                        
                }
            }
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}
#Preview {
    GoalsView()
}
