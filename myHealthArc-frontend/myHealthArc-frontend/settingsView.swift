//
//  settingsView.swift
//  myHealthArc-frontend
//
//  Created by Anjali Hole on 10/9/24.
//

import SwiftUI

//move this to a common file later
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
    }
}

struct SettingsView: View {
    @State private var appleHealth = false
    @State private var appleFitness = false
    // Environment variable to access current color scheme
        @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
            
            Toggle("Apple Health", isOn: $appleHealth){
                Text("Enables integration with Apple Health")
            }
                .toggleStyle(.switch)
                .padding()
            
            Toggle("Apple Fitness", isOn: $appleFitness){
                Text("Enables integration with Apple Fitness")
            }
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
