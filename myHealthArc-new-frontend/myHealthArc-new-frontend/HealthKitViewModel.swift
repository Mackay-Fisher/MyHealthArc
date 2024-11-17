//
//  HealthKitViewModel.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/6/24.
//
import SwiftUI
import HealthKit

struct HealthKitTestView: View {
    @State private var generatedUserHash = UUID().uuidString // New user hash for testing
    @State private var statusMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("HealthKit Testing Interface")
                .font(.title)
                .padding()

            // Display the generated user hash for testing purposes
            Text("Current Test User Hash:")
            Text(generatedUserHash)
                .font(.headline)
                .foregroundColor(.blue)
                .padding()

            // Button to regenerate a new user hash and send fake data to the backend
            Button(action: {
                generatedUserHash = UUID().uuidString // Generate a new hash each time button is pressed
                HealthKitManager.shared.sendDummyHealthDataToBackend(userHash: generatedUserHash)
                statusMessage = "Fake data sent with user hash: \(generatedUserHash)"
            }) {
                Text("Send Fake Data")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            // Display status message to inform if the data was sent
            Text(statusMessage)
                .foregroundColor(.green)
                .padding()
        }
        .padding()
    }
}

struct HealthKitTestView_Previews: PreviewProvider {
    static var previews: some View {
        HealthKitTestView()
    }
}

// HealthKitManager Extension for Testing
extension HealthKitManager {
    func sendDummyHealthDataToBackend(userHash: String) {
        let dummyHealthData = [
            HealthData(type: "steps", value: 1500),
            HealthData(type: "heartRate", value: 75),
            HealthData(type: "calories", value: 1200),
            HealthData(type: "height", value: 1.75),
            HealthData(type: "weight", value: 70.0)
        ]

        sendHealthDataToBackend(dummyHealthData, userHash: userHash)
    }
}
