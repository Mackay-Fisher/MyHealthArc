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
    @Published var stepCount: Int
    @Published var exerciseMinutes: Int
    @Published var caloriesBurned: Int
    @Published var timeAsleep: Int
    @Published var waterIntake: Int
    @Published var workoutsPerWeek: Int
    @Published var proteinGoal: Int
    @Published var carbsGoal: Int
    @Published var fatGoal: Int
    @Published var caloriesConsumed: Int

    // Streak variables
    @Published var stepsStreak: Int
    @Published var exerciseStreak: Int
    @Published var calBurnedStreak: Int
    @Published var sleepStreak: Int
    @Published var waterStreak: Int
    @Published var workoutsStreak: Int
    @Published var nutritionStreak: Int

    private let apiClient = APIClient()
    private let userHash = "dummy_user_hash"

    init() {
        // Load saved defaults as initial values
        stepCount = UserDefaults.standard.integer(forKey: "stepCount")
        exerciseMinutes = UserDefaults.standard.integer(forKey: "exerciseMinutes")
        caloriesBurned = UserDefaults.standard.integer(forKey: "caloriesBurned")
        timeAsleep = UserDefaults.standard.integer(forKey: "timeAsleep")
        waterIntake = UserDefaults.standard.integer(forKey: "waterIntake")
        workoutsPerWeek = UserDefaults.standard.integer(forKey: "workoutsPerWeek")
        proteinGoal = UserDefaults.standard.integer(forKey: "proteinGoal")
        carbsGoal = UserDefaults.standard.integer(forKey: "carbsGoal")
        fatGoal = UserDefaults.standard.integer(forKey: "fatGoal")
        caloriesConsumed = UserDefaults.standard.integer(forKey: "caloriesConsumed")

        stepsStreak = UserDefaults.standard.integer(forKey: "stepsStreak")
        exerciseStreak = UserDefaults.standard.integer(forKey: "exerciseStreak")
        calBurnedStreak = UserDefaults.standard.integer(forKey: "calBurnedStreak")
        sleepStreak = UserDefaults.standard.integer(forKey: "sleepStreak")
        waterStreak = UserDefaults.standard.integer(forKey: "waterStreak")
        workoutsStreak = UserDefaults.standard.integer(forKey: "workoutsStreak")
        nutritionStreak = UserDefaults.standard.integer(forKey: "nutritionStreak")

        // Fetch latest data from API
        fetchGoalsFromAPI()
        fetchStreaksFromAPI()
    }

    // MARK: - API Calls
    private func fetchGoalsFromAPI() {
        apiClient.fetchGoals(userHash: userHash) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let goals):
                    self?.updateGoalsFromAPI(goals: goals)
                case .failure(let error):
                    print("Failed to fetch goals: \(error)")
                }
            }
        }
    }

    private func fetchStreaksFromAPI() {
        apiClient.fetchStreaks(userHash: userHash) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let streaks):
                    self?.updateStreaksFromAPI(streaks: streaks)
                case .failure(let error):
                    print("Failed to fetch streaks: \(error)")
                }
            }
        }
    }

    // MARK: - Update Methods
    private func updateGoalsFromAPI(goals: [String: Int]) {
        stepCount = goals["stepCount"] ?? stepCount
        exerciseMinutes = goals["exerciseMinutes"] ?? exerciseMinutes
        caloriesBurned = goals["caloriesBurned"] ?? caloriesBurned
        timeAsleep = goals["timeAsleep"] ?? timeAsleep
        waterIntake = goals["waterIntake"] ?? waterIntake
        workoutsPerWeek = goals["workoutsPerWeek"] ?? workoutsPerWeek
        proteinGoal = goals["proteinGoal"] ?? proteinGoal
        carbsGoal = goals["carbsGoal"] ?? carbsGoal
        fatGoal = goals["fatGoal"] ?? fatGoal
        caloriesConsumed = goals["caloriesConsumed"] ?? caloriesConsumed

        saveGoalsToUserDefaults()
    }

    private func updateStreaksFromAPI(streaks: [String: Int]) {
        stepsStreak = streaks["stepsStreak"] ?? stepsStreak
        exerciseStreak = streaks["exerciseStreak"] ?? exerciseStreak
        calBurnedStreak = streaks["calBurnedStreak"] ?? calBurnedStreak
        sleepStreak = streaks["sleepStreak"] ?? sleepStreak
        waterStreak = streaks["waterStreak"] ?? waterStreak
        workoutsStreak = streaks["workoutsStreak"] ?? workoutsStreak
        nutritionStreak = streaks["nutritionStreak"] ?? nutritionStreak

        saveStreaksToUserDefaults()
    }

    // MARK: - Persistence
    private func saveGoalsToUserDefaults() {
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

    private func saveStreaksToUserDefaults() {
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
    
    var streaks: [FitnessGoal] {
            [
                FitnessGoal(name: "Steps", value: stepsStreak, color: GoalColors.steps),
                FitnessGoal(name: "Exercise", value: exerciseStreak, color: GoalColors.exercise),
                FitnessGoal(name: "Calories Burned", value: calBurnedStreak, color: GoalColors.calories),
                FitnessGoal(name: "Sleep", value: sleepStreak, color: GoalColors.sleep),
                FitnessGoal(name: "Water", value: waterStreak, color: GoalColors.water),
                FitnessGoal(name: "Workouts", value: workoutsStreak, color: GoalColors.workouts),
                FitnessGoal(name: "Nutrition", value: nutritionStreak, color: GoalColors.nutrition)
            ]
        }

        func loadGoalsAndStreaks() {
            let apiClient = APIClient()
            let userHash = "dummy-user-hash" // Replace with dynamic user hash as needed
            
            apiClient.fetchGoals(userHash: userHash) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let goals):
                        self.stepCount = goals["stepCount"] ?? self.stepCount
                        self.exerciseMinutes = goals["exerciseMinutes"] ?? self.exerciseMinutes
                        // Map other goals here...
                    case .failure(let error):
                        print("Failed to fetch goals: \(error)")
                    }
                }
            }
            
            apiClient.fetchStreaks(userHash: userHash) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let streaks):
                        self.stepsStreak = streaks["stepsStreak"] ?? self.stepsStreak
                        self.exerciseStreak = streaks["exerciseStreak"] ?? self.exerciseStreak
                        // Map other streaks here...
                    case .failure(let error):
                        print("Failed to fetch streaks: \(error)")
                    }
                }
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

    func checkNutritionGoals(protein: Int, carbs: Int, fat: Int, calories: Int) -> Bool {
        let proteinMet = protein >= proteinGoal
        let carbsMet = carbs >= carbsGoal
        let fatMet = fat >= fatGoal
        let caloriesMet = calories <= caloriesConsumed

        return proteinMet && carbsMet && fatMet && caloriesMet
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
