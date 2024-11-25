//
//  AppleHealthManager.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/18/24.
//


import HealthKit
import Foundation

class AppleHealthManager {
    static let shared = AppleHealthManager()
    private let healthStore = HKHealthStore()

    // Request permissions for Apple Health data
    func requestPermissions(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Health data is not available on this device."]))
            return
        }

        let readTypes: Set<HKObjectType> = [
            // Body Measurements
            HKQuantityType.quantityType(forIdentifier: .bodyMass)!,
            HKQuantityType.quantityType(forIdentifier: .height)!,
            HKQuantityType.quantityType(forIdentifier: .bodyMassIndex)!,

            // Vital Signs
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKQuantityType.quantityType(forIdentifier: .respiratoryRate)!,

            // Sleep
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            completion(success, error)
        }
    }

    // Fetch Body Measurements
    func fetchBodyMeasurements() async throws -> [HealthData] {
        let height = try await fetchMostRecentQuantitySample(for: .height, unit: .meter(), typeName: "height")
        let weight = try await fetchMostRecentQuantitySample(for: .bodyMass, unit: .gramUnit(with: .kilo), typeName: "bodyMass")
        let bmi = try await fetchMostRecentQuantitySample(for: .bodyMassIndex, unit: .count(), typeName: "bodyMassIndex")
        return [height, weight, bmi].compactMap { $0 }
    }

    // Fetch Sleep Data
    func fetchSleepData() async throws -> [HealthData] {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
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

    // Fetch Vital Signs (e.g., Heart Rate, Blood Pressure)
    func fetchVitalSigns() async throws -> [HealthData] {
        let heartRate = try await fetchMostRecentQuantitySample(for: .heartRate, unit: HKUnit(from: "count/min"), typeName: "heartRate")
        let systolic = try await fetchMostRecentQuantitySample(for: .bloodPressureSystolic, unit: .millimeterOfMercury(), typeName: "bloodPressureSystolic")
        let diastolic = try await fetchMostRecentQuantitySample(for: .bloodPressureDiastolic, unit: .millimeterOfMercury(), typeName: "bloodPressureDiastolic")
        let respiratoryRate = try await fetchMostRecentQuantitySample(for: .respiratoryRate, unit: .count().unitDivided(by: .minute()), typeName: "respiratoryRate")
        return [heartRate, systolic, diastolic, respiratoryRate].compactMap { $0 }
    }
    func fetchHistoricalData(
        for identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [(String, Double)] {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            return []
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let data = samples?.compactMap { sample -> (String, Double)? in
                    guard let sample = sample as? HKQuantitySample else { return nil }
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    let timeString = formatter.string(from: sample.endDate)
                    return (timeString, sample.quantity.doubleValue(for: unit))
                } ?? []
                
                continuation.resume(returning: data)
            }
            
            healthStore.execute(query)
        }
    }

    // Helper to fetch the most recent quantity sample
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
}

// Define the model for HealthData
struct HealthData: Codable {
    let type: String
    let value: Double
}
