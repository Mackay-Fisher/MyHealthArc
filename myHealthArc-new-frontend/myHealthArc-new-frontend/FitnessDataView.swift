//
//  FitnessDataView.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/18/24.
//

import SwiftUI
import HealthKit

struct FitnessDataView: View { // Height passed from the parent view

    @State private var stepCount: Int = 0
    @State private var caloriesBurned: Int = 0
    @State private var distance: Double = 0.0 // in miles
    @State private var exerciseTime: Int = 0 // in minutes
    @State private var flightsClimbed: Int = 0 // in flights
    @State private var moveMinutes: Int = 0 // Move minutes

    private let healthStore = HKHealthStore()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Text("🏃‍♂️ Apple Fitness Data")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Summary")
                        .font(.headline)
                        .foregroundColor(.gray)
                }

                // Manage Goals Button
                HStack {
                    Text("Manage Goals")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)

                // Data Widgets Grid
                LazyVGrid(columns: [GridItem(.flexible(minimum: 150)), GridItem(.flexible(minimum: 150))], spacing: 20) {
                    FitnessWidget(
                        title: "Step Count",
                        value: "\(stepCount)",
                        goal: "10,000",
                        progress: Double(stepCount) / 10000,
                        icon: "figure.walk",
                        iconColor: .blue
                    )

                    FitnessWidget(
                        title: "Calories Burned",
                        value: "\(caloriesBurned) kcal",
                        goal: "400 kcal",
                        progress: Double(caloriesBurned) / 400,
                        icon: "flame.fill",
                        iconColor: .red
                    )

                    FitnessWidget(
                        title: "Distance",
                        value: "\(String(format: "%.2f", distance)) mi",
                        goal: "1.0 mi",
                        progress: distance / 1.0,
                        icon: "map.fill",
                        iconColor: .green
                    )

                    FitnessWidget(
                        title: "Exercise Time",
                        value: "\(exerciseTime) min",
                        goal: "60 min",
                        progress: Double(exerciseTime) / 60,
                        icon: "dumbbell.fill",
                        iconColor: .purple
                    )

                    FitnessWidget(
                        title: "Flights Climbed",
                        value: "\(flightsClimbed)",
                        goal: "20",
                        progress: Double(flightsClimbed) / 20,
                        icon: "airplane.departure",
                        iconColor: .orange
                    )

                    FitnessWidget(
                        title: "Move Minutes",
                        value: "\(moveMinutes) min",
                        goal: "30 min",
                        progress: Double(moveMinutes) / 30,
                        icon: "clock.fill",
                        iconColor: .yellow
                    )
                }
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            fetchFitnessData()
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
            self.stepCount = Int(value)
            dispatchGroup.leave()
        }

        // Fetch calories burned
        dispatchGroup.enter()
        fetchQuantity(for: .activeEnergyBurned, unit: HKUnit.kilocalorie(), predicate: predicate) { value in
            self.caloriesBurned = Int(value)
            dispatchGroup.leave()
        }

        // Fetch distance walked
        dispatchGroup.enter()
        fetchQuantity(for: .distanceWalkingRunning, unit: HKUnit.mile(), predicate: predicate) { value in
            self.distance = value
            dispatchGroup.leave()
        }

        // Fetch exercise time
        dispatchGroup.enter()
        fetchQuantity(for: .appleExerciseTime, unit: HKUnit.minute(), predicate: predicate) { value in
            self.exerciseTime = Int(value)
            dispatchGroup.leave()
        }

        // Fetch flights climbed
        dispatchGroup.enter()
        fetchQuantity(for: .flightsClimbed, unit: HKUnit.count(), predicate: predicate) { value in
            self.flightsClimbed = Int(value)
            dispatchGroup.leave()
        }

        // Fetch move minutes
        dispatchGroup.enter()
        fetchQuantity(for: .appleStandTime, unit: HKUnit.minute(), predicate: predicate) { value in
            self.moveMinutes = Int(value)
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

            Text("To Go: \(goal)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
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
