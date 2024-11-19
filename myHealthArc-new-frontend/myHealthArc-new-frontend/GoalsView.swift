//
//  GoalsView.swift
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
    // MARK: - Published Properties
    //idk if this is correct ngl
    @Published var stepCount: Int {
        didSet { saveGoals() }
    }
    @Published var exerciseMinutes: Int {
        didSet { saveGoals() }
    }
    @Published var caloriesBurned: Int {
        didSet { saveGoals() }
    }
    @Published var timeAsleep: Int {
        didSet { saveGoals() }
    }
    @Published var waterIntake: Int {
        didSet { saveGoals() }
    }
    @Published var workoutsPerWeek: Int {
        didSet { saveGoals() }
    }
    @Published var proteinGoal: Int {
        didSet { saveGoals() }
    }
    @Published var carbsGoal: Int {
        didSet { saveGoals() }
    }
    @Published var fatGoal: Int {
        didSet { saveGoals() }
    }
    @Published var caloriesConsumed: Int {
        didSet { saveGoals() }
    }
    
    // Streak variables
    @Published var stepsStreak: Int {
        didSet { saveStreaks() }
    }
    @Published var exerciseStreak: Int {
        didSet { saveStreaks() }
    }
    @Published var calBurnedStreak: Int {
        didSet { saveStreaks() }
    }
    @Published var sleepStreak: Int {
        didSet { saveStreaks() }
    }
    @Published var waterStreak: Int {
        didSet { saveStreaks() }
    }
    @Published var workoutsStreak: Int {
        didSet { saveStreaks() }
    }
    @Published var nutritionStreak: Int {
        didSet { saveStreaks() }
    }
    
    init() {
        // Initialize with default values
        self.stepCount = UserDefaults.standard.integer(forKey: "stepCount")
        self.exerciseMinutes = UserDefaults.standard.integer(forKey: "exerciseMinutes")
        self.caloriesBurned = UserDefaults.standard.integer(forKey: "caloriesBurned")
        self.timeAsleep = UserDefaults.standard.integer(forKey: "timeAsleep")
        self.waterIntake = UserDefaults.standard.integer(forKey: "waterIntake")
        self.workoutsPerWeek = UserDefaults.standard.integer(forKey: "workoutsPerWeek")
        self.proteinGoal = UserDefaults.standard.integer(forKey: "proteinGoal")
        self.carbsGoal = UserDefaults.standard.integer(forKey: "carbsGoal")
        self.fatGoal = UserDefaults.standard.integer(forKey: "fatGoal")
        self.caloriesConsumed = UserDefaults.standard.integer(forKey: "caloriesConsumed")
        
        // Initialize streaks - 0
        self.stepsStreak = UserDefaults.standard.integer(forKey: "stepsStreak")
        self.exerciseStreak = UserDefaults.standard.integer(forKey: "exerciseStreak")
        self.calBurnedStreak = UserDefaults.standard.integer(forKey: "calBurnedStreak")
        self.sleepStreak = UserDefaults.standard.integer(forKey: "sleepStreak")
        self.waterStreak = UserDefaults.standard.integer(forKey: "waterStreak")
        self.workoutsStreak = UserDefaults.standard.integer(forKey: "workoutsStreak")
        self.nutritionStreak = UserDefaults.standard.integer(forKey: "nutritionStreak")
        
        // If no saved values exist, set defaults
        if stepCount == 0 { self.stepCount = 10000 }
        if exerciseMinutes == 0 { self.exerciseMinutes = 30 }
        if caloriesBurned == 0 { self.caloriesBurned = 500 }
        if timeAsleep == 0 { self.timeAsleep = 8 }
        if waterIntake == 0 { self.waterIntake = 8 }
        if workoutsPerWeek == 0 { self.workoutsPerWeek = 6 }
        if proteinGoal == 0 { self.proteinGoal = 60 }
        if carbsGoal == 0 { self.carbsGoal = 300 }
        if fatGoal == 0 { self.fatGoal = 50 }
        if caloriesConsumed == 0 { self.caloriesConsumed = 2200 }
    }
    
    // MARK: - Persistence Functions

    private func saveGoals() {
        UserDefaults.standard.set(stepCount, forKey: "stepCount")
        UserDefaults.standard.set(exerciseMinutes, forKey: "exerciseMinutes")
        UserDefaults.standard.set(caloriesBurned, forKey: "caloriesBurned")
        UserDefaults.standard.set(timeAsleep, forKey: "timeAsleep")
        UserDefaults.standard.set(waterIntake, forKey: "waterIntake")
        UserDefaults.standard.set(workoutsPerWeek, forKey: "workoutsPerWeek")
        UserDefaults.standard.set(proteinGoal, forKey: "proteinGoal")
        UserDefaults.standard.set(carbsGoal, forKey: "carbsGoal")
        UserDefaults.standard.set(fatGoal, forKey: "fatGoal")
        UserDefaults.standard.set(caloriesConsumed, forKey: "caloriesConsumed")
    }
    
    private func saveStreaks() {
        UserDefaults.standard.set(stepsStreak, forKey: "stepsStreak")
        UserDefaults.standard.set(exerciseStreak, forKey: "exerciseStreak")
        UserDefaults.standard.set(calBurnedStreak, forKey: "calBurnedStreak")
        UserDefaults.standard.set(sleepStreak, forKey: "sleepStreak")
        UserDefaults.standard.set(waterStreak, forKey: "waterStreak")
        UserDefaults.standard.set(workoutsStreak, forKey: "workoutsStreak")
        UserDefaults.standard.set(nutritionStreak, forKey: "nutritionStreak")
    }
    
    // MARK: - Streak Functions
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
        if meetsNutritionGoals {
            nutritionStreak += 1
        } else {
            nutritionStreak = 0
        }
    }
    
    //check if nutrition goals are met
    func checkNutritionGoals(protein: Int, carbs: Int, fat: Int, calories: Int) -> Bool {
        let proteinMet = protein >= proteinGoal
        let carbsMet = carbs >= carbsGoal
        let fatMet = fat >= fatGoal
        let caloriesMet = calories <= caloriesConsumed
        
        return proteinMet && carbsMet && fatMet && caloriesMet
    }
    
    //create streak array
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
}

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
    
    
    // Add state to track current progress
    @State private var currentSteps = 0
    @State private var currentExerciseMinutes = 0
    @State private var currentCaloriesBurned = 0
    @State private var currentSleepHours = 0
    @State private var currentWaterGlasses = 0
    @State private var currentWorkouts = 0
    @State private var currentProtein = 0
    @State private var currentCarbs = 0
    @State private var currentFat = 0
    @State private var currentCalories = 0
    
    private func checkAndUpdateStreaks() {
        viewModel.updateStepsStreak(stepsCompleted: currentSteps)
        viewModel.updateExerciseStreak(minutesCompleted: currentExerciseMinutes)
        viewModel.updateCalorieStreak(caloriesBurnedToday: currentCaloriesBurned)
        viewModel.updateSleepStreak(hoursSlept: currentSleepHours)
        viewModel.updateWaterStreak(glassesConsumed: currentWaterGlasses)
        viewModel.updateWorkoutStreak(workoutsCompleted: currentWorkouts)
        
        let nutritionGoalsMet = viewModel.checkNutritionGoals(
            protein: currentProtein,
            carbs: currentCarbs,
            fat: currentFat,
            calories: currentCalories
        )
        viewModel.updateNutritionStreak(meetsNutritionGoals: nutritionGoalsMet)
    }
    
    //idk if this actually will work just tried something
    private func setupDailyStreakCheck() {
        Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { _ in
            checkAndUpdateStreaks()
        }
    }
    
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
                        // MARK: - Streaks Section
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
                                    StreakFlameView(streak: streak)
                                }
                            }
                        }
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // MARK: - Fitness Goals Section
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
                        
                        // MARK: - Nutrition Goals Section
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
        .onAppear {
            setupDailyStreakCheck()
        }
    }
}
//MARK: - Plus/Minus Button functionality
struct GoalAdjusterView: View {
    let title: String
    @Binding var value: Int
    let unit: String
    let step: Int
    //TODO: fix the colors later w everything else
    private var buttonColor: Color {
        switch title {
        case "Step Count":
            return GoalColors.steps
        case "Exercise Minutes":
            return GoalColors.exercise
        case "Calories Burned":
            return GoalColors.calories
        case "Time Asleep":
            return GoalColors.sleep
        case "Water Intake":
            return GoalColors.water
        case "Workouts":
            return GoalColors.workouts
        case "Protein":
            return GoalColors.nutrition
        case "Carbs":
            return GoalColors.nutrition
        case "Fats":
            return GoalColors.nutrition
        case "Calories Consumed":
            return GoalColors.nutrition
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
                Button(action: {
                    if value > step {  // Prevent negative values
                        value -= step
                    }
                }) {
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
//MARK: - Streaks flame thing - THEY GROW WITH THE NUMBER OF STREAKSSSSSSugheruighe
struct StreakFlameView: View {
    let streak: FitnessGoal
    
    private var flameSize: CGFloat {
        // Adjust size based on streak value
        let baseSize: CGFloat = 30
        let maxIncrease: CGFloat = 15
        let increase = min(CGFloat(streak.value) / 30.0, 1.0) * maxIncrease
        return baseSize + increase
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(streak.name)
                .font(.caption)
            
            ZStack {
                // Background glow
                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(streak.color.opacity(0.2))
                    .frame(width: flameSize + 10, height: flameSize + 10)
                
                // Main flame
                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()

                    .foregroundColor(streak.color)
                    .frame(width: flameSize, height: flameSize)
                Image(systemName: "flame")
                    .resizable()
                    .scaledToFit()

                    .foregroundColor(streak.color)
                    .frame(width: flameSize+1, height: flameSize+1)
                
                // Value
                Text("\(streak.value)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    //.offset(y: -2)
            }
            .frame(height: 60)
        }
    }
}


// Preview provider
struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView()
            .preferredColorScheme(.light)
        
        GoalsView()
            .preferredColorScheme(.dark)
    }
}
