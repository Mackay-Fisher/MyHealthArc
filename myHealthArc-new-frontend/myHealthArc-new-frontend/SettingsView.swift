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
import LocalAuthentication
import SwiftKeychainWrapper

struct SettingsView: View {
    @State private var appleHealth: Bool = false
    @State private var appleFitness: Bool = false
    @State private var prescription: Bool = false
    @State private var nutrition: Bool = false
    @AppStorage("isFaceIDEnabled") private var isFaceIDEnabled: Bool = false
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
                
                Section{
                    Toggle("Apple Health", isOn: $appleHealth)
                        .font(.system(size: 18))
                        .toggleStyle(.switch)
                        .tint(Color.mhaGreen)
                        .padding()
                        .frame(width:300)
                }
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .cornerRadius(20)
                
                Spacer().frame(height: 20)
                
                Section{
                    Toggle("Apple Fitness", isOn: $appleFitness)
                        .font(.system(size: 18))
                        .toggleStyle(.switch)
                        .tint(Color.mhaGreen)
                        .padding()
                        .frame(width:300)
                }
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .cornerRadius(20)
                
                Spacer().frame(height: 20)
                
                Section{
                    Toggle("Prescriptions", isOn: $prescription)
                        .font(.system(size: 18))
                        .toggleStyle(.switch)
                        .tint(Color.mhaGreen)
                        .padding()
                        .frame(width:300)
                }
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .cornerRadius(20)
                
                Spacer().frame(height: 20)
                
                Section{
                    Toggle("Nutrition", isOn: $nutrition)
                        .font(.system(size: 18))
                        .toggleStyle(.switch)
                        .tint(Color.mhaGreen)
                        .padding()
                        .frame(width:300)
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
                    //TODO: fix the navigation here
                    NavigationLink(destination: EditProfilePage()) {
                        Text("Edit Profile")
                    }
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                }
                .padding()
                .frame(width: 300 , height:50)
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .cornerRadius(20)
                
                Spacer().frame(height: 20)

                Section {
                    Toggle("Enable FaceID", isOn: $isFaceIDEnabled)
                        .onChange(of: isFaceIDEnabled) { value in
                            if value {
                                enableFaceID()
                            } else {
                                disableFaceID()
                            }
                        }
                        .font(.system(size: 18))
                        .toggleStyle(.switch)
                        .tint(Color.mhaGreen)
                        .padding()
                        .frame(width: 300)
                }
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

    private func enableFaceID() {
        let context = LAContext()
        var error: NSError?
        print("Attempting to enable FaceID")

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            print("Biometrics are available")
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Enable FaceID") { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isFaceIDEnabled = true
                        print("FaceID enabled successfully")
                        KeychainWrapper.standard.set(true, forKey: "isFaceIDEnabled")
                        if let userHash = KeychainWrapper.standard.string(forKey: "userHash") {
                            KeychainWrapper.standard.set(userHash, forKey: "userHash")
                            print("KeychainWrapper: userHash saved")
                        } else {
                            print("KeychainWrapper: Failed to retrieve userHash")
                        }
                    } else {
                        if let error = authenticationError {
                            print("Authentication failed: \(error.localizedDescription)")
                        }
                        isFaceIDEnabled = false
                    }
                }
            }
        } else {
            if let error = error {
                print("Biometrics not available: \(error.localizedDescription)")
            }
            isFaceIDEnabled = false
        }
    }

    private func disableFaceID() {
        KeychainWrapper.standard.removeObject(forKey: "isFaceIDEnabled")
        isFaceIDEnabled = false
    }
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // @Previewable
        @State var isLoggedIn: Bool = false
        @State var hasSignedUp: Bool = false
        SettingsView(isLoggedIn: $isLoggedIn , hasSignedUp: $hasSignedUp)
    }
}

