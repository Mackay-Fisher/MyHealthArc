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
                                .foregroundColor(.mhaGreen)
                            
                            Text("Apple Fitness")
                                .font(.headline)
                                //.padding(.top)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            //.padding(.top)
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
                                    .fontWeight(.semibold)
                                Text("cal")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 2)
                            }
                        }
                        Divider() // Vertical divider
                               .frame(height: 40)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Exercise")
                                .foregroundColor(.mhaGreen)
                                .font(.subheadline)
                                .fontWeight(.semibold)
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
                        Divider() // Vertical divider
                               .frame(height: 40)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Stand")
                                .foregroundColor(.mhaBlue)
                                .font(.subheadline)
                                .fontWeight(.semibold)
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
            requestAuthorization()
        }
    }
    
    // MARK: - Authorization
    private func requestAuthorization() {
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKCategoryType.categoryType(forIdentifier: .appleStandHour)!
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
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        // Fetch calories burned
        if let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            let query = HKStatisticsQuery(quantityType: caloriesType,
                                        quantitySamplePredicate: predicate,
                                        options: .cumulativeSum) { _, result, error in
                if let sum = result?.sumQuantity() {
                    DispatchQueue.main.async {
                        self.caloriesBurned = Int(sum.doubleValue(for: HKUnit.kilocalorie()))
                    }
                }
            }
            healthStore.execute(query)
        }
        
        // Fetch exercise time
        if let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) {
            let query = HKStatisticsQuery(quantityType: exerciseType,
                                        quantitySamplePredicate: predicate,
                                        options: .cumulativeSum) { _, result, error in
                if let sum = result?.sumQuantity() {
                    DispatchQueue.main.async {
                        self.exerciseTime = Int(sum.doubleValue(for: HKUnit.minute()))
                    }
                }
            }
            healthStore.execute(query)
        }
        
        // Fetch stand hours
        if let standType = HKCategoryType.categoryType(forIdentifier: .appleStandHour) {
            let query = HKSampleQuery(
                sampleType: standType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                guard let samples = samples as? [HKCategorySample] else { return }
                
                // Filter for only the successful stand hours (value of 0 means stood, 1 means not stood)
                let standHourCount = samples.filter { $0.value == HKCategoryValueAppleStandHour.stood.rawValue }.count
                
                DispatchQueue.main.async {
                    self.standHours = standHourCount
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
