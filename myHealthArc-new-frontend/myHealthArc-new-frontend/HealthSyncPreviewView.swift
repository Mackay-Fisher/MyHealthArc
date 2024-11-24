import SwiftUI
import HealthKit

struct HealthSyncPreviewView: View {
    @State private var authorizationStatus: String = "Not Requested"
    @State private var healthData: [String] = []
    @State private var fitnessData: [String] = []
    private let healthStore = HKHealthStore()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Health Sync Preview")
                    .font(.largeTitle)
                    .bold()

                // Authorization Status
                Text("Authorization Status: \(authorizationStatus)")
                    .foregroundColor(.gray)

                // Request Authorization Button
                Button(action: requestAuthorization) {
                    Text("Request HealthKit Authorization")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                // Fetch Health Data Button
                Button(action: fetchHealthData) {
                    Text("Fetch Health Data")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                // Fetch Fitness Data Button
                Button(action: fetchFitnessData) {
                    Text("Fetch Fitness Data")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                // Health Data Display
                if !healthData.isEmpty {
                    Text("Health Data")
                        .font(.headline)
                    ScrollView {
                        ForEach(healthData, id: \.self) { item in
                            Text(item).padding(5)
                        }
                    }
                    .frame(height: 150)
                }

                // Fitness Data Display
                if !fitnessData.isEmpty {
                    Text("Fitness Data")
                        .font(.headline)
                    ScrollView {
                        ForEach(fitnessData, id: \.self) { item in
                            Text(item).padding(5)
                        }
                    }
                    .frame(height: 150)
                }

                Spacer()
            }
            .padding()
            .navigationBarTitle("Health Sync")
        }
    }
    
    func requestHealthKitAuthorization() async -> Bool {
        let healthTypesToRead: Set<HKObjectType> = [
            // Heart-related metrics
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,

            // Respiratory metrics
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,

            // Energy-related metrics
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,

            // Physical activity metrics
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,

            // Body measurements
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
            HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!,
            HKObjectType.quantityType(forIdentifier: .leanBodyMass)!,

            // Sleep analysis
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,

            // Nutrition metrics
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
            HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
            HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!,

            // Blood metrics
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodGlucose)!,
            HKObjectType.quantityType(forIdentifier: .bloodAlcoholContent)!,

            // Environmental metrics
            HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)!,
            HKObjectType.quantityType(forIdentifier: .uvExposure)!,

            // Reproductive health
            HKObjectType.categoryType(forIdentifier: .menstrualFlow)!,
            HKObjectType.categoryType(forIdentifier: .ovulationTestResult)!,
            HKObjectType.categoryType(forIdentifier: .sexualActivity)!
        ]

        do {
            try await HKHealthStore().requestAuthorization(toShare: [], read: healthTypesToRead)
            print("HealthKit authorization requested.")
            return true
        } catch {
            print("HealthKit authorization failed:", error.localizedDescription)
            return false
        }
    }
   

    // MARK: - Request Authorization
    func requestAuthorization() {
        Task {
            let success = await requestHealthKitAuthorization()
            DispatchQueue.main.async {
                authorizationStatus = success ? "Authorized" : "Denied"
            }
        }
    }

    // MARK: - Fetch Health Data
    func fetchHealthData() {
        Task {
            let types: [HKQuantityTypeIdentifier] = [
                .heartRate,
                .respiratoryRate,
                .heartRateVariabilitySDNN
            ]

            var fetchedHeartRate: [[String: Any]] = []
            var fetchedOtherData: [String] = []
            let group = DispatchGroup()

            for typeIdentifier in types {
                guard let sampleType = HKSampleType.quantityType(forIdentifier: typeIdentifier) else { continue }

                group.enter()
                let query = HKSampleQuery(
                    sampleType: sampleType,
                    predicate: nil,
                    limit: 10,
                    sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
                ) { query, samples, error in
                    defer { group.leave() }

                    if let samples = samples as? [HKQuantitySample] {
                        for sample in samples {
                            let unit: HKUnit
                            switch typeIdentifier {
                            case .heartRate:
                                unit = HKUnit.count().unitDivided(by: HKUnit.minute())
                                fetchedHeartRate.append([
                                    "timestamp": sample.startDate,
                                    "value": sample.quantity.doubleValue(for: unit)
                                ])
                            case .respiratoryRate:
                                unit = HKUnit.count().unitDivided(by: HKUnit.minute())
                            case .heartRateVariabilitySDNN:
                                unit = HKUnit.secondUnit(with: .milli)
                            default:
                                unit = HKUnit.count()
                            }

                            if typeIdentifier != .heartRate {
                                let value = sample.quantity.doubleValue(for: unit)
                                let entry = "\(typeIdentifier.rawValue): \(value) \(unit.unitString) (from \(sample.startDate) to \(sample.endDate))"
                                fetchedOtherData.append(entry)
                            }
                        }
                    } else if let error = error {
                        print("Error fetching \(typeIdentifier.rawValue):", error.localizedDescription)
                    }
                }

                healthStore.execute(query)
            }

            group.notify(queue: .main) {
                healthData = fetchedHeartRate.isEmpty ? ["No heart rate data found"] : fetchedHeartRate.map {
                    "Heart Rate: \($0["value"]!) at \($0["timestamp"]!)"
                }
                print("Final Heart Rate Data:", fetchedHeartRate)

                if !fetchedOtherData.isEmpty {
                    healthData.append(contentsOf: fetchedOtherData)
                }
            }
        }
    }

    // MARK: - Fetch Fitness Data
    func fetchFitnessData() {
        Task {
            let types: [HKQuantityTypeIdentifier] = [
                .stepCount,
                .distanceWalkingRunning,
                .activeEnergyBurned
            ]

            var fetchedData: [String] = []
            let group = DispatchGroup()

            for typeIdentifier in types {
                guard let sampleType = HKSampleType.quantityType(forIdentifier: typeIdentifier) else { continue }

                group.enter()
                let query = HKSampleQuery(
                    sampleType: sampleType,
                    predicate: nil,
                    limit: 10,
                    sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
                ) { query, samples, error in
                    defer { group.leave() }

                    if let samples = samples as? [HKQuantitySample] {
                        for sample in samples {
                            let unit: HKUnit
                            switch typeIdentifier {
                            case .stepCount:
                                unit = HKUnit.count()
                            case .distanceWalkingRunning:
                                unit = HKUnit.meter()
                            case .activeEnergyBurned:
                                unit = HKUnit.kilocalorie()
                            default:
                                unit = HKUnit.count()
                            }

                            let value = sample.quantity.doubleValue(for: unit)
                            let startDate = sample.startDate
                            let endDate = sample.endDate
                            let entry = "\(typeIdentifier.rawValue): \(value) \(unit.unitString) (from \(startDate) to \(endDate))"
                            fetchedData.append(entry)
                            print("Fetched \(typeIdentifier.rawValue): \(entry)")
                        }
                    } else if let error = error {
                        print("Error fetching \(typeIdentifier.rawValue):", error.localizedDescription)
                    }
                }

                healthStore.execute(query)
            }

            group.notify(queue: .main) {
                fitnessData = fetchedData.isEmpty ? ["No data found"] : fetchedData
                print("Final Fitness Data:", fetchedData)
            }
        }
    }
}
