//
//  settingsView.swift
//  myHealthArc-frontend
//
//  Created by Anjali Hole on 10/9/24.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
            
            Toggle("Apple Health", isOn: .constant(true))
                .padding()
            
            Toggle("Apple Fitness", isOn: .constant(false))
                .padding()
            
            Button("Delete Account") {
                // Handle delete account action
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
