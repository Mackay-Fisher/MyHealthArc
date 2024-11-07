import Vapor

#if canImport(HealthKit)
import HealthKit

struct HealthDataController: RouteCollection {
    let healthStore = HKHealthStore()
    
    func boot(routes: RoutesBuilder) throws {
        let healthData = routes.grouped("healthData")
        healthData.get("summary", use: self.getHealthDataSummary)
    }
    
    @Sendable
    func getHealthDataSummary(req: Request) async throws -> [HealthData] {
        // Decode the list of data types from the query parameter
        guard let dataTypesParam = try? req.query.get(String.self, at: "dataTypes") else {
            throw Abort(.badRequest, reason: "A 'dataTypes' parameter is required, with comma-separated HealthKit data types.")
        }
        
        // Split the comma-separated data types
        let dataTypes = dataTypesParam.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        // Placeholder for results
        var healthDataResults: [HealthData] = []
        
        // Authorization Request
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.workoutType()
        ]
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if !success {
                    continuation.resume(throwing: Abort(.forbidden, reason: "HealthKit authorization was not granted."))
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
        
        // Loop through each data type and fetch its information
        for dataType in dataTypes {
            switch dataType {
            case "steps":
                let stepData = try await fetchStepCount()
                healthDataResults.append(stepData)
            case "heartRate":
                let heartRateData = try await fetchHeartRate()
                healthDataResults.append(heartRateData)
            case "workouts":
                let workoutData = try await fetchWorkouts()
                healthDataResults.append(workoutData)
            default:
                throw Abort(.badRequest, reason: "Unsupported data type requested: \(dataType)")
            }
        }
        
        // Return the list of health data summaries
        return healthDataResults
    }
    
    @Sendable
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
    
    @Sendable
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

    
    @Sendable
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

}

#endif

// Define a model for HealthData that represents each data type's response
struct HealthData: Content {
    var type: String
    var value: Double // or other relevant fields based on data type
}