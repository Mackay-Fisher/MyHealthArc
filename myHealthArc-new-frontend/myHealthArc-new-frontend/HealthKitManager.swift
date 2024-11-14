import HealthKit
import Foundation

class HealthKitManager {
    static let shared = HealthKitManager()
    public let healthStore = HKHealthStore()
    func fetchHealthData() async throws -> [HealthData] {
            var allHealthData: [HealthData] = []

            do {
                allHealthData += try await fetchBodyMeasurements()
                allHealthData.append(try await fetchStepCount())
                allHealthData.append(try await fetchHeartRate())
                allHealthData += try await fetchWorkouts()
                allHealthData += try await fetchNutritionData()
                allHealthData += try await fetchSleepData()
            } catch {
                throw error
            }

            return allHealthData
        }
    func requestPermissionsIfNeeded() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let requiredTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
            HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
            HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]

        let authorizationStatuses = requiredTypes.map { healthStore.authorizationStatus(for: $0) }
        
        if authorizationStatuses.contains(.notDetermined) {
            requestPermissions()
        } else {
            fetchAndUploadData()
        }
    }
    
    private func requestPermissions() {
        let readTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
            HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
            HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        
        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            if let error = error {
                print("Error requesting permissions: \(error.localizedDescription)")
            } else if success {
                print("HealthKit authorization succeeded.")
                self.fetchAndUploadData()
            }
        }
    }

    private func fetchAndUploadData() {
        Task {
            do {
                var healthData: [HealthData] = []
                
                healthData += try await fetchBodyMeasurements()
                healthData.append(try await fetchStepCount())
                healthData.append(try await fetchHeartRate())
                healthData += try await fetchWorkouts()
                healthData += try await fetchNutritionData()
                healthData += try await fetchSleepData()
                
                sendHealthDataToBackend(healthData)
            } catch {
                print("Error fetching HealthKit data: \(error)")
            }
        }
    }
    // Fetch the step count for the current day
    func fetchStepCount() async throws -> HealthData {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let sum = result?.sumQuantity() else {
                    continuation.resume(returning: HealthData(type: "steps", value: 0))
                    return
                }
                let steps = sum.doubleValue(for: HKUnit.count())
                continuation.resume(returning: HealthData(type: "steps", value: steps))
            }
            healthStore.execute(query)
        }
    }
    
    // Fetch the average heart rate over the past hour
    func fetchHeartRate() async throws -> HealthData {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let heartRates = (samples as? [HKQuantitySample])?.map { $0.quantity.doubleValue(for: HKUnit(from: "count/min")) } ?? []
                let averageHeartRate = heartRates.isEmpty ? 0 : heartRates.reduce(0, +) / Double(heartRates.count)
                continuation.resume(returning: HealthData(type: "heartRate", value: averageHeartRate))
            }
            healthStore.execute(query)
        }
    }

    // Fetch workout data for the current day, calculating total calories burned
    func fetchWorkouts() async throws -> [HealthData] {
        let workoutType = HKObjectType.workoutType()
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // Collect workout data: calculate total calories burned and create HealthData entries for each workout
                let workoutData = (samples as? [HKWorkout])?.map { workout in
                    HealthData(type: "workout", value: workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0)
                } ?? []
                
                continuation.resume(returning: workoutData)
            }
            healthStore.execute(query)
        }
    }
    private func fetchBodyMeasurements() async throws -> [HealthData] {
        let height = try await fetchMostRecentQuantitySample(for: .height, unit: .meter(), typeName: "height")
        let weight = try await fetchMostRecentQuantitySample(for: .bodyMass, unit: .gramUnit(with: .kilo), typeName: "bodyMass")
        let bmi = try await fetchMostRecentQuantitySample(for: .bodyMassIndex, unit: .count(), typeName: "bodyMassIndex")
        return [height, weight, bmi].compactMap { $0 }
    }

    private func fetchNutritionData() async throws -> [HealthData] {
        let calories = try await fetchMostRecentQuantitySample(for: .dietaryEnergyConsumed, unit: .kilocalorie(), typeName: "calories")
        let protein = try await fetchMostRecentQuantitySample(for: .dietaryProtein, unit: .gram(), typeName: "protein")
        let carbs = try await fetchMostRecentQuantitySample(for: .dietaryCarbohydrates, unit: .gram(), typeName: "carbohydrates")
        let fat = try await fetchMostRecentQuantitySample(for: .dietaryFatTotal, unit: .gram(), typeName: "fat")
        return [calories, protein, carbs, fat].compactMap { $0 }
    }
    
    private func fetchSleepData() async throws -> [HealthData] {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let sleepData = samples?.compactMap { sample -> HealthData? in
                    guard let categorySample = sample as? HKCategorySample else { return nil }
                    let type = categorySample.value == HKCategoryValueSleepAnalysis.inBed.rawValue ? "inBed" : "asleep"
                    return HealthData(type: type, value: categorySample.endDate.timeIntervalSince(categorySample.startDate) / 3600) // Time in hours
                } ?? []
                continuation.resume(returning: sleepData)
            }
            healthStore.execute(query)
        }
    }

    private func fetchMostRecentQuantitySample(for identifier: HKQuantityTypeIdentifier, unit: HKUnit, typeName: String) async throws -> HealthData? {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else { return nil }
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                let value = sample.quantity.doubleValue(for: unit)
                continuation.resume(returning: HealthData(type: typeName, value: value))
            }
            healthStore.execute(query)
        }
    }
    func sendDummyHealthDataToBackend() {
           // Define dummy health data
           let dummyHealthData = [
               HealthData(type: "steps", value: 1500),
               HealthData(type: "heartRate", value: 75),
               HealthData(type: "calories", value: 1200),
               HealthData(type: "height", value: 1.75),
               HealthData(type: "weight", value: 70.0)
           ]
           
           // Send the dummy data to the backend
           sendHealthDataToBackend(dummyHealthData)
       }
       
       private func sendHealthDataToBackend(_ healthData: [HealthData]) {
           guard let url = URL(string: "https://your-backend-url.com/healthData/summary") else { return }
           
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")

           do {
               let jsonData = try JSONEncoder().encode(healthData)
               request.httpBody = jsonData
               
               let task = URLSession.shared.dataTask(with: request) { data, response, error in
                   if let error = error {
                       print("Error sending health data to backend: \(error.localizedDescription)")
                       return
                   }
                   print("Health data successfully sent to backend.")
               }
               task.resume()
           } catch {
               print("Error encoding health data: \(error.localizedDescription)")
           }
       }
}

// Define the model for HealthData
struct HealthData: Codable {
    var type: String
    var value: Double
}
