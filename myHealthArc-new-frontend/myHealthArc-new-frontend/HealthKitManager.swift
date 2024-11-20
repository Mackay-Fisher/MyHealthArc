//  HealthKitManager.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/18/24.
//
import HealthKit
import BackgroundTasks

class HealthKitBackgroundManager {
    private let healthStore = HKHealthStore()
    private var healthAnchor: HKQueryAnchor? // Anchor for health data updates
    private var fitnessAnchor: HKQueryAnchor? // Anchor for fitness data updates

    static let shared = HealthKitBackgroundManager() // Singleton instance

    private init() {}

    // MARK: - Background Task Registration
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.myapp.healthSync", using: nil) { task in
            self.handleMasterUpdate(task: task as! BGAppRefreshTask)
        }
    }

    // MARK: - Schedule Background Master Sync
    func scheduleBackgroundMasterSync() {
        let request = BGAppRefreshTaskRequest(identifier: "com.myapp.healthSync")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Every 15 minutes

        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background master sync scheduled.")
        } catch {
            print("Failed to schedule background master sync: \(error.localizedDescription)")
        }
    }

    // MARK: - Handle Master Update Task
    func handleMasterUpdate(task: BGAppRefreshTask) {
        task.expirationHandler = {
            print("Background task expired before completion.")
        }

        Task {
            print("Starting periodic background sync...")
            guard await self.requestHealthKitAuthorization() else {
                print("HealthKit authorization not granted.")
                task.setTaskCompleted(success: false)
                return
            }

            self.syncMasterData { success in
                print("Periodic background sync completed: \(success ? "Success" : "Failure")")
                task.setTaskCompleted(success: success)

                // Schedule the next background sync
                self.scheduleBackgroundMasterSync()
            }
        }
    }

    // MARK: - Perform Master Sync
    func syncMasterData(completion: @escaping (Bool) -> Void) {
        print("Starting master sync...")
        let group = DispatchGroup()
        var success = true

        group.enter()
        syncHealthData { result in
            print("Health data sync completed: \(result ? "Success" : "Failure")")
            success = success && result
            group.leave()
        }

        group.enter()
        syncFitnessData { result in
            print("Fitness data sync completed: \(result ? "Success" : "Failure")")
            success = success && result
            group.leave()
        }

        group.notify(queue: .main) {
            print("Master sync completed: \(success ? "Success" : "Failure")")
            completion(success)
        }
    }

}

extension HealthKitBackgroundManager {
    // MARK: - Request HealthKit Authorization
    func requestHealthKitAuthorization() async -> Bool {
        let healthTypesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: healthTypesToRead)
            return true
        } catch {
            print("HealthKit authorization failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Health Data Sync
    func syncHealthData(completion: @escaping (Bool) -> Void) {
        let healthTypes: [HKQuantityTypeIdentifier] = [.heartRate]

        performAnchoredQuery(for: healthTypes, anchor: healthAnchor) { samples, newAnchor in
            self.healthAnchor = newAnchor // Update the stored anchor for health data
            self.syncSamplesToDatabase(samples: samples, category: "health")
            completion(true)
        }
    }

    // MARK: - Fitness Data Sync
    func syncFitnessData(completion: @escaping (Bool) -> Void) {
        let fitnessTypes: [HKQuantityTypeIdentifier] = [.stepCount, .activeEnergyBurned, .distanceWalkingRunning]

        performAnchoredQuery(for: fitnessTypes, anchor: fitnessAnchor) { samples, newAnchor in
            self.fitnessAnchor = newAnchor // Update the stored anchor for fitness data
            self.syncSamplesToDatabase(samples: samples, category: "fitness")
            completion(true)
        }
    }

    // MARK: - Perform Anchored Query
    private func performAnchoredQuery(for types: [HKQuantityTypeIdentifier], anchor: HKQueryAnchor?, completion: @escaping ([HKQuantitySample], HKQueryAnchor?) -> Void) {
        let group = DispatchGroup()
        var allSamples: [HKQuantitySample] = []
        var latestAnchor: HKQueryAnchor? = anchor // Create a local copy of the anchor

        for type in types {
            guard let sampleType = HKSampleType.quantityType(forIdentifier: type) else { continue }
            group.enter()

            let query = HKAnchoredObjectQuery(
                type: sampleType,
                predicate: nil,
                anchor: latestAnchor,
                limit: HKObjectQueryNoLimit
            ) { query, samplesOrNil, _, newAnchor, error in
                defer { group.leave() } // Ensure `group.leave()` is always called
                guard let samples = samplesOrNil as? [HKQuantitySample] else {
                    print("Error fetching HealthKit data: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                allSamples.append(contentsOf: samples)
                latestAnchor = newAnchor // Update the latest anchor
            }

            healthStore.execute(query)
        }

        group.notify(queue: .main) {
            completion(allSamples, latestAnchor) // Return both samples and the updated anchor
        }
    }

    // MARK: - Sync Samples to Database
    private func syncSamplesToDatabase(samples: [HKQuantitySample], category: String) {
        // Map HealthKit samples to dictionaries for JSON serialization
        let dataToSync = samples.map { sample -> [String: Any] in
            return [
                "startDate": ISO8601DateFormatter().string(from: sample.startDate),
                "endDate": ISO8601DateFormatter().string(from: sample.endDate),
                "value": sample.quantity.doubleValue(for: HKUnit.count()), // Adjust the unit as needed
                "type": sample.quantityType.identifier,
                "category": category,
                "userHash": "realUserHash123" // Replace with actual user identifier if available
            ]
        }

        // Wrap the array in a dictionary
        let payload: [String: Any] = [
            "data": dataToSync
        ]

        // Print the data being sent for debugging
        print("\n===== Data Being Sent for \(category.capitalized) Sync =====")
        print(payload)
        print("====================================================\n")

        // Ensure the URL is valid
        guard let url = URL(string: "https://bbc6-198-217-29-75.ngrok-free.app/healthFitness/update\(category.capitalized)") else {
            print("Invalid URL for \(category).")
            return
        }

        // Prepare the HTTP request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            // Serialize the payload into JSON
            let body = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = body

            // Perform the request
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error syncing \(category) data: \(error.localizedDescription)")
                } else if let httpResponse = response as? HTTPURLResponse {
                    print("\(category.capitalized) data sync response: \(httpResponse.statusCode)")
                }

                // Log response body for debugging
                if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                    print("\(category.capitalized) data sync response body: \(responseBody)")
                }
            }.resume()
        } catch {
            print("Error serializing \(category) data: \(error.localizedDescription)")
        }
    }


}

extension Date {
    func iso8601String() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
