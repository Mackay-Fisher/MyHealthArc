//
//  FitnessWidgetView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 11/22/24.
//


import SwiftUI
import HealthKit

struct FitnessWidgetView: View {
    @State private var showFullFitnessView = false
    @Environment(\.colorScheme) var colorScheme
    
    // States for fitness data
    @State private var caloriesBurned: Int?
    @State private var exerciseTime: Int?
    @State private var standHours: Int?
    
    private let healthStore = HKHealthStore()
    
    var body: some View {
        VStack {
            NavigationLink(destination: FitnessDataView(), isActive: $showFullFitnessView) {
                EmptyView()
            }
            
            Button(action: {
                showFullFitnessView = true
            }) {
                VStack(alignment: .leading, spacing: 20) {
                    // Title Section
                    HStack {
                        Spacer()
                        HStack {
                            Image(systemName: "figure.run")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25)
                                .foregroundColor(.green)
                            
                            Text("Apple Fitness")
                                .font(.headline)
                                .padding(.top)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .padding(.top)
                            .foregroundColor(colorScheme == .dark ? Color.lightbackground : Color.gray)
                    }
                    
                    Divider()
                    
                    // Fitness Data Display
                    HStack(spacing: 30) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Move")
                                .foregroundColor(.pink)
                                .font(.subheadline)
                            HStack(alignment: .bottom, spacing: 4) {
                                Text("\(caloriesBurned ?? 0)")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                Text("cal")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 2)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Exercise")
                                .foregroundColor(.green)
                                .font(.subheadline)
                            HStack(alignment: .bottom, spacing: 4) {
                                Text("\(exerciseTime ?? 0)")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                Text("min")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 2)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Stand")
                                .foregroundColor(.blue)
                                .font(.subheadline)
                            HStack(alignment: .bottom, spacing: 4) {
                                Text("\(standHours ?? 0)")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                Text("hrs")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 2)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 10)
                }
                .padding()
                .frame(width: 350)
                .background(colorScheme == .dark ? Color.mhaGray : Color.white)
                .cornerRadius(30)
                .shadow(radius: 0.2)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
        .onAppear {
            fetchFitnessData()
        }
    }
    
    // MARK: - Fetch Fitness Data
    private func fetchFitnessData() {
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        // Fetch calories burned
        if let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            let query = HKStatisticsQuery(quantityType: caloriesType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                DispatchQueue.main.async {
                    let calories = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie())
                    self.caloriesBurned = Int(calories ?? 0)
                }
            }
            healthStore.execute(query)
        }
        
        // Fetch exercise time
        if let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) {
            let query = HKStatisticsQuery(quantityType: exerciseType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                DispatchQueue.main.async {
                    let minutes = result?.sumQuantity()?.doubleValue(for: HKUnit.minute())
                    self.exerciseTime = Int(minutes ?? 0)
                }
            }
            healthStore.execute(query)
        }
        
        // Fetch stand hours
        if let standType = HKQuantityType.quantityType(forIdentifier: .appleStandTime) {
            let query = HKStatisticsQuery(quantityType: standType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                DispatchQueue.main.async {
                    let hours = (result?.sumQuantity()?.doubleValue(for: HKUnit.minute()) ?? 0) / 60.0
                    self.standHours = Int(hours)
                }
            }
            healthStore.execute(query)
        }
    }
}

struct FitnessWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessWidgetView()
    }
}
