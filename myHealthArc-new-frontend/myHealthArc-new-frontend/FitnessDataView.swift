//
//  FitnessDataView.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/18/24.
//

import SwiftUI
import HealthKit

struct FitnessDataView: View {
    @State private var stepCount: Int?
    @State private var caloriesBurned: Int?
    @State private var distance: Double? // in miles
    @State private var exerciseTime: Int? // in minutes
    @State private var flightsClimbed: Int? // in flights
    @State private var moveMinutes: Int? // Move minutes
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

                // Manage Goals Button
//                HStack {
//                    Text("Manage Goals")
//                        .font(.headline)
//                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
//                    Spacer()
//                    Image(systemName: "chevron.right")
//                        .foregroundColor(.gray)
//                }
//                .padding()
//                .background(Color(.systemGray6))
//                .cornerRadius(15)
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
                .padding(.horizontal)

                // Data Widgets Grid
                LazyVGrid(columns: [GridItem(.flexible(minimum: 150)), GridItem(.flexible(minimum: 150))], spacing: 20) {
                    if let stepCount = stepCount, stepCount > 0 {
                        FitnessWidget(
                            title: "Step Count",
                            value: "\(stepCount)",
                            goal: "10,000",
                            progress: Double(stepCount) / 10000,
                            icon: "figure.walk",
                            iconColor: .mhaBlue
                        )
                    }

                    if let caloriesBurned = caloriesBurned, caloriesBurned > 0 {
                        FitnessWidget(
                            title: "Calories Burned",
                            value: "\(caloriesBurned) kcal",
                            goal: "400 kcal",
                            progress: Double(caloriesBurned) / 400,
                            icon: "flame.fill",
                            iconColor: .mhaSalmon
                        )
                    }

                    if let distance = distance, distance > 0 {
                        FitnessWidget(
                            title: "Distance",
                            value: "\(String(format: "%.2f", distance)) mi",
                            goal: "1.0 mi",
                            progress: distance / 1.0,
                            icon: "map.fill",
                            iconColor: .mhaGreen
                        )
                    }

                    if let exerciseTime = exerciseTime, exerciseTime > 0 {
                        FitnessWidget(
                            title: "Exercise Time",
                            value: "\(exerciseTime) min",
                            goal: "60 min",
                            progress: Double(exerciseTime) / 60,
                            icon: "dumbbell.fill",
                            iconColor: .mhaPurple
                        )
                    }

                    if let flightsClimbed = flightsClimbed, flightsClimbed > 0 {
                        FitnessWidget(
                            title: "Flights Climbed",
                            value: "\(flightsClimbed)",
                            goal: "20",
                            progress: Double(flightsClimbed) / 20,
                            icon: "airplane.departure",
                            iconColor: .mhaOrange
                        )
                    }

                    if let moveMinutes = moveMinutes, moveMinutes > 0 {
                        FitnessWidget(
                            title: "Move Minutes",
                            value: "\(moveMinutes) min",
                            goal: "30 min",
                            progress: Double(moveMinutes) / 30,
                            icon: "clock.fill",
                            iconColor: .mhaYellow
                        )
                    }
                }
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all))
        .onAppear {
            requestAuthorization()
        }
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
                    .frame(width: 40, height: 40) // Ensure the icon has a fixed size
                    .foregroundColor(iconColor)
            }
            .frame(width: 100, height: 100) // Ensure the circle size is consistent

            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity) // Make the text wrap if needed

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            HStack{
                Image(systemName: "checkmark.arrow.trianglehead.counterclockwise")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .foregroundColor(.mhaGreen)
                Text("To Go: \(goal)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .frame(width: 170, height: 230) // Fixed size for the entire widget
    }
}


// Preview
struct FitnessDataView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessDataView()
            .preferredColorScheme(.dark)
    }
}
