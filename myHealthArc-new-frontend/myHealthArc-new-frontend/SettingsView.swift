//
//  SettingsView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/17/24.
//TODO: add logout method
import SwiftUI

struct SettingsView: View {
    @State private var appleHealth: Bool = false
    @State private var appleFitness: Bool = false
    @State private var prescription: Bool = false
    @State private var nutrition: Bool = false
    
    @Binding var isLoggedIn: Bool
    @Binding var hasSignedUp: Bool

    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Divider()
                    .overlay(colorScheme == .dark ? Color.white : Color.gray)

                Text("Toggle Services")
                    .font(.title2)
                    .padding()
                
                Section {
                    Toggle("Apple Health", isOn: $appleHealth)
                        .font(.system(size: 18))
                        .toggleStyle(.switch)
                        .tint(Color.mhaGreen)
                        .padding()
                        .frame(width: 300)
                        .onChange(of: appleHealth) { isEnabled in
                            handleToggleChange(for: .health, isEnabled: isEnabled)
                        }
                }
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .cornerRadius(20)
                
                Spacer().frame(height: 20)
                
                Section {
                    Toggle("Apple Fitness", isOn: $appleFitness)
                        .font(.system(size: 18))
                        .toggleStyle(.switch)
                        .tint(Color.mhaGreen)
                        .padding()
                        .frame(width: 300)
                        .onChange(of: appleFitness) { isEnabled in
                            handleToggleChange(for: .fitness, isEnabled: isEnabled)
                        }
                }
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .cornerRadius(20)
                
                Spacer().frame(height: 20)
                
                Section {
                    Toggle("Prescriptions", isOn: $prescription)
                        .font(.system(size: 18))
                        .toggleStyle(.switch)
                        .tint(Color.mhaGreen)
                        .padding()
                        .frame(width: 300)
                }
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .cornerRadius(20)
                
                Spacer().frame(height: 20)
                
                Section {
                    Toggle("Nutrition", isOn: $nutrition)
                        .font(.system(size: 18))
                        .toggleStyle(.switch)
                        .tint(Color.mhaGreen)
                        .padding()
                        .frame(width: 300)
                }
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .cornerRadius(20)
                
                Spacer().frame(height: 20)
                
                Divider()
                    .overlay(colorScheme == .dark ? Color.white : Color.gray)

                Text("Manage Account")
                    .font(.title2)
                    .padding()

                Section {
                    NavigationLink(destination: EditProfilePage()) {
                        Text("Edit Profile")
                    }
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                }
                .padding()
                .frame(width: 300, height: 50)
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .cornerRadius(20)
                
                Spacer().frame(height: 20)

                Button("Logout") {
                    hasSignedUp = false
                    isLoggedIn = false
                }
                .fontWeight(.bold)
                .foregroundColor(.red)
                .frame(width: 200, height: 50)
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black : Color.lightbackground)
    }
    
    // Handle toggle changes to enable or disable background tasks
    private func handleToggleChange(for service: HealthKitService, isEnabled: Bool) {
        switch service {
        case .health:
            if isEnabled {
                print("Apple Health enabled. Scheduling background sync.")
                HealthKitBackgroundManager.shared.scheduleBackgroundMasterSync()
            }
        case .fitness:
            if isEnabled {
                print("Apple Fitness enabled. Scheduling background sync.")
                HealthKitBackgroundManager.shared.scheduleBackgroundMasterSync()
            }
        }
    }
}

// Enum to differentiate services
enum HealthKitService {
    case health
    case fitness
}

// Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isLoggedIn: Bool = true
        @State var hasSignedUp: Bool = true
        SettingsView(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp)
            .preferredColorScheme(.dark)
    }
}
