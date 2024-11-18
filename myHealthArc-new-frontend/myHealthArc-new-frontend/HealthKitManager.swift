//
//  HealthKitManager.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/18/24.
//
import HealthKit
import BackgroundTasks

class HealthKitBackgroundManager {
    private let healthStore = HKHealthStore()
    private var anchor: HKQueryAnchor? // Store the anchor for incremental updates

    static let shared = HealthKitBackgroundManager() // Singleton instance

    private init() {}

    // MARK: - Background Task Registration
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.myapp.healthSync", using: nil) { task in
            self.handleBackgroundHealthSync(task: task as! BGAppRefreshTask)
        }
    }

    // MARK: - Schedule Background Health Sync
    func scheduleBackgroundHealthSync() {
        let request = BGAppRefreshTaskRequest(identifier: "com.myapp.healthSync")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Schedule every 15 minutes

        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background sync scheduled.")
        } catch {
            print("Failed to schedule background sync: \(error.localizedDescription)")
        }
    }

    // MARK: - Handle Background Task
    func handleBackgroundHealthSync(task: BGAppRefreshTask) {
        task.expirationHandler = {
            print("Background task expired before completion.")
        }

        // Perform sync
        Task {
            self.syncHealthData { success in
                task.setTaskCompleted(success: success)
            }
        }
    }

    // MARK: - Start Observing HealthKit Changes
    func startObservingHealthData() {
        observeHealthKitChanges(for: .stepCount)
        observeHealthKitChanges(for: .activeEnergyBurned)
        observeHealthKitChanges(for: .distanceWalkingRunning)
        observeHealthKitChanges(for: .heartRate)
    }

    private func observeHealthKitChanges(for quantityType: HKQuantityTypeIdentifier) {
        guard let sampleType = HKSampleType.quantityType(forIdentifier: quantityType) else { return }

        let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { [weak self] _, completionHandler, error in
            if let error = error {
                print("Observer error: \(error.localizedDescription)")
                return
            }

            // Fetch new data and sync it to the database
            self?.startAnchoredQuery(for: quantityType) { samples in
                self?.syncSamplesToDatabase(samples: samples)
            }

            // Notify HealthKit that you're done processing the update
            completionHandler()
        }

        healthStore.execute(query)
        healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { success, error in
            if let error = error {
                print("Error enabling background delivery: \(error.localizedDescription)")
            } else {
                print("Background delivery enabled for \(quantityType.rawValue).")
            }
        }
    }

    // MARK: - Start Anchored Query
    private func startAnchoredQuery(for quantityType: HKQuantityTypeIdentifier, completion: @escaping ([HKQuantitySample]) -> Void) {
        guard let sampleType = HKSampleType.quantityType(forIdentifier: quantityType) else { return }

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

            // Save the new anchor for future incremental updates
            self.anchor = newAnchor

            // Return the fetched samples
            completion(samples)
        }

        query.updateHandler = { query, samplesOrNil, deletedObjectsOrNil, newAnchor, error in
            guard let samples = samplesOrNil as? [HKQuantitySample] else { return }
            self.anchor = newAnchor
            completion(samples)
        }

        healthStore.execute(query)
    }

    // MARK: - Sync HealthKit Data to Database
    private func syncSamplesToDatabase(samples: [HKQuantitySample]) {
        let dataToSync = samples.map { sample -> [String: Any] in
            return [
                "startDate": sample.startDate,
                "endDate": sample.endDate,
                "value": sample.quantity.doubleValue(for: HKUnit.count()), // Adjust the unit as needed
                "type": sample.quantityType.identifier
            ]
        }

        // Send data to your backend database
        guard let url = URL(string: "https://your-backend.com/health-data") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let body = try JSONSerialization.data(withJSONObject: dataToSync, options: [])
            request.httpBody = body

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error syncing data to database: \(error.localizedDescription)")
                } else {
                    print("HealthKit data successfully synced to database.")
                }
            }.resume()
        } catch {
            print("Error serializing data: \(error.localizedDescription)")
        }
    }

    // MARK: - Perform Full Sync
    func syncHealthData(completion: @escaping (Bool) -> Void) {
        let types: [HKQuantityTypeIdentifier] = [.stepCount, .activeEnergyBurned, .distanceWalkingRunning, .heartRate]

        let group = DispatchGroup()
        var success = true

        for type in types {
            group.enter()
            startAnchoredQuery(for: type) { samples in
                self.syncSamplesToDatabase(samples: samples)
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(success)
        }
    }
}
