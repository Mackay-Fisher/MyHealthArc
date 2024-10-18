//
//  SettingsView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/17/24.
//


//
//  settingsView.swift
//  myHealthArc-frontend
//
//  Created by Anjali Hole on 10/9/24.
//
//TODO: add logout method
import SwiftUI

struct SettingsView: View {
    @State private var appleHealth: Bool = false
    @State private var appleFitness: Bool = false


    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
            
            Toggle("Apple Health", isOn: $appleHealth)
                .toggleStyle(.switch)
                .padding()
            
            Toggle("Apple Fitness", isOn: $appleFitness)
                .toggleStyle(.switch)
                .padding()
            
            Button("Delete Account") {
                // Handle delete account action
                print("Account Deleted")
            }
            .frame(width: 200, height: 50)
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}
#Preview {
    SettingsView()
}
