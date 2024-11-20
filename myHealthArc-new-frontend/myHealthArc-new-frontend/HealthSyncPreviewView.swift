//
//  HealthSyncPreviewView.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/19/24.
//


import SwiftUI

struct HealthSyncPreviewView: View {
    @State private var authorizationStatus: String = "Not Requested"
    @State private var syncStatus: String = "Idle"

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Health Sync Preview")
                    .font(.largeTitle)
                    .bold()
                
                // Authorization Status
                Text("Authorization Status: \(authorizationStatus)")
                    .foregroundColor(.gray)

                // Sync Status
                Text("Sync Status: \(syncStatus)")
                    .foregroundColor(syncStatus == "Success" ? .green : .red)

                // Request Access Button
                Button(action: requestAccess) {
                    Text("Request HealthKit Access")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                // Sync Databases Button
                Button(action: syncDatabases) {
                    Text("Sync Health & Fitness Data")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Spacer()
            }
            .padding()
            .navigationBarTitle("Health Sync")
        }
    }

    // MARK: - Request HealthKit Access
    func requestAccess() {
        Task {
            let authorized = await HealthKitBackgroundManager.shared.requestHealthKitAuthorization()
            authorizationStatus = authorized ? "Authorized" : "Denied"
        }
    }

    // MARK: - Sync Databases
    func syncDatabases() {
        syncStatus = "Syncing..."
        HealthKitBackgroundManager.shared.syncMasterData { success in
            DispatchQueue.main.async {
                syncStatus = success ? "Success" : "Failure"
            }
        }
    }
}
