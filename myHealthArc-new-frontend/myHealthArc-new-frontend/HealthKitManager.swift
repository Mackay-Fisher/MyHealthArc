import HealthKit
import Foundation

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    func requestPermissionsIfNeeded() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let workoutType = HKObjectType.workoutType()

        if healthStore.authorizationStatus(for: stepType) != .sharingAuthorized ||
           healthStore.authorizationStatus(for: heartRateType) != .sharingAuthorized ||
           healthStore.authorizationStatus(for: workoutType) != .sharingAuthorized {
            requestPermissions()
        } else {
            fetchAndUploadData()
        }
    }
    
    private func requestPermissions() {
        let readTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.workoutType()
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
                let stepData = try await fetchStepCount()
                let heartRateData = try await fetchHeartRate()
                let workoutData = try await fetchWorkouts()
                
                let healthData = [stepData, heartRateData, workoutData]
                sendHealthDataToBackend(healthData)
            } catch {
                print("Error fetching HealthKit data: \(error)")
            }
        }
    }

    private func fetchStepCount() async throws -> HealthData {
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
    
    private func fetchHeartRate() async throws -> HealthData {
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

    private func fetchWorkouts() async throws -> HealthData {
        let workoutType = HKObjectType.workoutType()
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let calories = (samples as? [HKWorkout])?.reduce(0) { $0 + ($1.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0) } ?? 0
                continuation.resume(returning: HealthData(type: "workouts", value: calories))
            }
            healthStore.execute(query)
        }
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

