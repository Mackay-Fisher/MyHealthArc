//
//  FitnessDataView.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/18/24.
//

import SwiftUI
import HealthKit
import SwiftKeychainWrapper

struct FitnessDataView: View {
    @State private var stepCount: Int?
    @State private var caloriesBurned: Int?
    @State private var distance: Double? // in miles
    @State private var exerciseTime: Int? // in minutes
    @State private var flightsClimbed: Int? // in flights
    @State private var moveMinutes: Int? // Move minutes
    @StateObject private var goalsManager = GoalsManager()
    @State private var isLoading = true
    @Environment(\.colorScheme) var colorScheme

    private let healthStore = HKHealthStore()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    HStack {
                        Image(systemName: "figure.run")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                            .foregroundColor(.mhaGreen)
                        
                        Text("Apple Fitness")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                    
                    Text("Summary")
                        .font(.headline)
                        .foregroundColor(.gray)
                }

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
                    .frame(maxWidth: .infinity)
                }

                if isLoading {
                    ProgressView("Loading fitness data...")
                } else {
                    // Data Widgets Grid
                    LazyVGrid(columns: [GridItem(.flexible(minimum: 150)), GridItem(.flexible(minimum: 150))], spacing: 20) {
                        if let stepCount = stepCount {
                            let goal = goalsManager.goals["step-count"] ?? 10000
                            FitnessWidget(
                                title: "Step Count",
                                value: "\(stepCount)",
                                goal: "\(goal)",
                                progress: Double(stepCount) / Double(goal),
                                icon: "figure.walk",
                                iconColor: .mhaBlue
                            )
                        }

                        if let caloriesBurned = caloriesBurned {
                            let goal = goalsManager.goals["calories-burned"] ?? 400
                            FitnessWidget(
                                title: "Calories Burned",
                                value: "\(caloriesBurned) kcal",
                                goal: "\(goal) kcal",
                                progress: Double(caloriesBurned) / Double(goal),
                                icon: "flame.fill",
                                iconColor: .mhaSalmon
                            )
                        }

                        if let distance = distance {
                            let goal = goalsManager.goals["distance-traveled"] ?? 1
                            FitnessWidget(
                                title: "Distance",
                                value: String(format: "%.2f mi", distance),
                                goal: "\(goal) mi",
                                progress: distance / Double(goal),
                                icon: "map.fill",
                                iconColor: .mhaGreen
                            )
                        }

                        if let exerciseTime = exerciseTime {
                            let goal = goalsManager.goals["exercise-minutes"] ?? 60
                            FitnessWidget(
                                title: "Exercise Time",
                                value: "\(exerciseTime) min",
                                goal: "\(goal) min",
                                progress: Double(exerciseTime) / Double(goal),
                                icon: "dumbbell.fill",
                                iconColor: .mhaPurple
                            )
                        }

                        if let flightsClimbed = flightsClimbed {
                            let goal = goalsManager.goals["elevation-gained"] ?? 20
                            FitnessWidget(
                                title: "Flights Climbed",
                                value: "\(flightsClimbed)",
                                goal: "\(goal)",
                                progress: Double(flightsClimbed) / Double(goal),
                                icon: "airplane.departure",
                                iconColor: .mhaOrange
                            )
                        }

                        if let moveMinutes = moveMinutes {
                            let goal = goalsManager.goals["time-asleep"] ?? 30
                            FitnessWidget(
                                title: "Move Minutes",
                                value: "\(moveMinutes) min",
                                goal: "\(goal) min",
                                progress: Double(moveMinutes) / Double(goal),
                                icon: "clock.fill",
                                iconColor: .mhaYellow
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all))
        .onAppear {
            isLoading = true
            requestAuthorization()
            let userId = KeychainWrapper.standard.string(forKey: "userHash") ?? ""
            Task {
                try await fetchGoals(userId: userId)
                isLoading = false
            }
        }
    }

    private func fetchGoals(userId: String) async throws{
        try await goalsManager.fetchGoals(from: "\(AppConfig.baseURL)/goals", userHash: userId)
    }
    // MARK: - Authorization
        private func requestAuthorization() {
            // Define the types we want to read
            let typesToRead: Set<HKObjectType> = [
                HKObjectType.quantityType(forIdentifier: .stepCount)!,
                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
                HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
                HKObjectType.quantityType(forIdentifier: .appleStandTime)!
            ]
            
            healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
                if success {
                    fetchFitnessData()
                } else if let error = error {
                    print("Authorization failed: \(error.localizedDescription)")
                }
            }
        }
    
    private func updateFitnessStreakIfNeeded() {
        // Iterate over all goals and check if they are met
        for (key, goalValue) in goalsManager.goals {
            var currentValue: Double = 0

            // Match the key to the respective fitness data
            switch key {
            case "step-count":
                currentValue = Double(stepCount ?? 0)
            case "calories-burned":
                currentValue = Double(caloriesBurned ?? 0)
            case "distance-traveled":
                currentValue = distance ?? 0
            case "exercise-minutes":
                currentValue = Double(exerciseTime ?? 0)
            case "elevation-gained":
                currentValue = Double(flightsClimbed ?? 0)
            case "time-asleep": // Assuming time-asleep refers to move minutes
                currentValue = Double(moveMinutes ?? 0)
            default:
                continue
            }

            // Check if the goal is met
            if currentValue >= Double(goalValue) {
                print("DEBUG - Goal met for \(key). Updating streak...")

                let userId = KeychainWrapper.standard.string(forKey: "userHash") ?? ""
                let urlString = "\(AppConfig.baseURL)/goals/streakgoalmatch"

                guard let url = URL(string: urlString) else {
                    print("DEBUG - Invalid URL for streak update.")
                    continue
                }

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let payload: [String: String] = [
                    "userId": userId,
                    "streakKey": key
                ]

                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                    request.httpBody = jsonData

                    URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            print("DEBUG - Error updating streak for \(key): \(error)")
                            return
                        }

                        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                            print("DEBUG - Streak updated successfully for \(key)!")
                        } else {
                            print("DEBUG - Failed to update streak for \(key). Response: \(String(describing: response))")
                        }
                    }.resume()
                } catch {
                    print("DEBUG - Error creating JSON payload for \(key): \(error)")
                }
            }
        }
    }


    // MARK: - Fetch Fitness Data
    private func fetchFitnessData() {
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        let dispatchGroup = DispatchGroup()

        // Fetch step count
        dispatchGroup.enter()
        fetchQuantity(for: .stepCount, unit: HKUnit.count(), predicate: predicate) { value in
            self.stepCount = value > 0 ? Int(value) : nil
            dispatchGroup.leave()
        }

        // Fetch calories burned
        dispatchGroup.enter()
        fetchQuantity(for: .activeEnergyBurned, unit: HKUnit.kilocalorie(), predicate: predicate) { value in
            self.caloriesBurned = value > 0 ? Int(value) : nil
            dispatchGroup.leave()
        }

        // Fetch distance walked
        dispatchGroup.enter()
        fetchQuantity(for: .distanceWalkingRunning, unit: HKUnit.mile(), predicate: predicate) { value in
            self.distance = value > 0 ? value : nil
            dispatchGroup.leave()
        }

        // Fetch exercise time
        dispatchGroup.enter()
        fetchQuantity(for: .appleExerciseTime, unit: HKUnit.minute(), predicate: predicate) { value in
            self.exerciseTime = value > 0 ? Int(value) : nil
            dispatchGroup.leave()
        }

        // Fetch flights climbed
        dispatchGroup.enter()
        fetchQuantity(for: .flightsClimbed, unit: HKUnit.count(), predicate: predicate) { value in
            self.flightsClimbed = value > 0 ? Int(value) : nil
            dispatchGroup.leave()
        }

        // Fetch move minutes
        dispatchGroup.enter()
        fetchQuantity(for: .appleStandTime, unit: HKUnit.minute(), predicate: predicate) { value in
            self.moveMinutes = value > 0 ? Int(value) : nil
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            print("All fitness data updated.")
            self.updateFitnessStreakIfNeeded() // Call the new function here
        }
    }


    // MARK: - Helper to Fetch Quantity
    private func fetchQuantity(for identifier: HKQuantityTypeIdentifier, unit: HKUnit, predicate: NSPredicate, completion: @escaping (Double) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            completion(0)
            return
        }

        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
            DispatchQueue.main.async {
                completion(value)
            }
        }

        healthStore.execute(query)
    }
}


// Widget Component
struct FitnessWidget: View {
    let title: String
    let value: String
    let goal: String
    let progress: Double
    let icon: String
    let iconColor: Color
    @Environment(\.colorScheme) var colorScheme
    
    // Helper function to extract numeric values
    private func extractNumeric(from string: String) -> Double {
        let numbers = string.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
        return Double(numbers) ?? 0
    }
    
    // Calculate remaining value
    private var remainingValue: String {
        let currentValue = extractNumeric(from: value)
        let goalValue = extractNumeric(from: goal)
        let remaining = max(0, goalValue - currentValue)
        
        
        // Handle different units based on the title
        if title == "Calories Burned" {
            return "\(Int(remaining)) kcal"
        } else if title == "Distance" {
            let currentValue = extractNumeric(from: value)/100
            let goalValue = extractNumeric(from: goal)
            let remaining = max(0, goalValue - currentValue)
            return String(format: "\(Float(remaining)) mi", remaining)
        } else if title.contains("Time") || title == "Move Minutes" {
            return "\(Int(remaining)) min"
        } else {
            return "\(Int(remaining))"
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .fill(Color(.systemGray5))

                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .fill(iconColor)
                    .rotationEffect(Angle(degrees: -90))

                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(iconColor)
            }
            .frame(width: 100, height: 100)

            Text(title)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                
            HStack {
                Image(systemName: "checkmark.arrow.trianglehead.counterclockwise")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .foregroundColor(.mhaGreen)
                Text("To Go: \(remainingValue)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .frame(width: 180, height: 230)
    }
}


// Preview
struct FitnessDataView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessDataView()
            .preferredColorScheme(.dark)
    }
}
