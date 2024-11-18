//
//  HealthKitManager.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/18/24.
//


import HealthKit

class HealthKitManager {
    private let healthStore = HKHealthStore()
    private var anchor: HKQueryAnchor? // Stores the anchor for incremental updates

    func startHealthKitObserver(for quantityType: HKQuantityTypeIdentifier, updateHandler: @escaping ([HKQuantitySample]) -> Void) {
        guard let sampleType = HKSampleType.quantityType(forIdentifier: quantityType) else { return }

        // Create an anchored query to get new data
        let query = HKAnchoredObjectQuery(
            type: sampleType,
            predicate: nil,
            anchor: anchor,
            limit: HKObjectQueryNoLimit
        ) { query, samplesOrNil, deletedObjectsOrNil, newAnchor, error in
            guard let samples = samplesOrNil as? [HKQuantitySample] else {
                print("Error fetching HealthKit data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Save the new anchor for the next incremental update
            self.anchor = newAnchor
            
            // Handle new samples
            updateHandler(samples)
        }
        
        query.updateHandler = { query, samplesOrNil, deletedObjectsOrNil, newAnchor, error in
            guard let samples = samplesOrNil as? [HKQuantitySample] else { return }
            self.anchor = newAnchor
            updateHandler(samples)
        }

        healthStore.execute(query)
    }
}
