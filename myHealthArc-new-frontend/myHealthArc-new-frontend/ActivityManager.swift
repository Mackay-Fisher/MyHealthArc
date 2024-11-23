//
//  ActivityManager.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/18/24.
//


import HealthKit
import Foundation

class ActivityManager {
    static let shared = ActivityManager()
    private let healthStore = HKHealthStore()

    // Request permissions for Activity Data
    func requestPermissions(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Health data is not available on this device."]))
            return
        }

        let readTypes: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.workoutType()
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            completion(success, error)
        }
    }

    // Fetch Step Count
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

    // Fetch Workouts
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
                
                let workoutData = (samples as? [HKWorkout])?.map { workout in
                    HealthData(type: "workout", value: workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0)
                } ?? []
                
                continuation.resume(returning: workoutData)
            }
            healthStore.execute(query)
        }
    }
}
