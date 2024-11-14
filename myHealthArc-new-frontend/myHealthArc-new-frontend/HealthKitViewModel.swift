//
//  HealthKitViewModel.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/6/24.
//
import SwiftUI
import HealthKit

struct HealthDataView: View {
    @State private var healthData: [HealthData] = []
    @State private var isAuthorized = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Health Data Summary")
                .font(.title)
                .padding()

            if isAuthorized {
                List(healthData, id: \.type) { data in
                    HStack {
                        Text(data.type.capitalized)
                        Spacer()
                        Text(String(format: "%.2f", data.value))
                    }
                }
                .listStyle(InsetGroupedListStyle())
            } else {
                Text("Please authorize HealthKit access to view data.")
                    .multilineTextAlignment(.center)
                    .padding()
            }

            Button(action: requestPermissions) {
                Text("Authorize and Fetch Data")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
        }
        .onAppear(perform: checkAuthorizationStatus)
    }
    
    // Check authorization status when view appears
    private func checkAuthorizationStatus() {
        isAuthorized = HealthKitManager.shared.healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .stepCount)!) == .sharingAuthorized
        if isAuthorized {
            fetchHealthData()
        }
    }
    
    // Request permissions and fetch data if granted
    private func requestPermissions() {
        HealthKitManager.shared.requestPermissionsIfNeeded()
        checkAuthorizationStatus()
        fetchHealthData()
    }
    
    // Fetch health data and update UI
    private func fetchHealthData() {
        Task {
            do {
                healthData = try await HealthKitManager.shared.fetchHealthData()
            } catch {
                errorMessage = "Failed to fetch data: \(error.localizedDescription)"
            }
        }
    }
}

struct HealthDataView_Previews: PreviewProvider {
    static var previews: some View {
        HealthDataView()
    }
}
