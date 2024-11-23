//
//  ServicesView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/17/24.
//
import SwiftUI
import LocalAuthentication
import SwiftKeychainWrapper

struct ServicesView: View {
    @Binding var isLoggedIn: Bool
    @Binding var hasSignedUp: Bool
    
    //@AppStorage("isFaceIDEnabled") private var isFaceIDEnabled: Bool = false
    @AppStorage("hasShownAlert") var hasShownAlert = false
    @Binding var showAlert: Bool

    @State private var selectedServices: Set<String> = []
    @Environment(\.colorScheme) var colorScheme
    @State private var userName: String = "User Name" // Placeholder for user name
    @State private var userEmail: String = "user@example.com" // Placeholder for user email
    @State private var showProfile: Bool = false // To toggle
    
    var services = ["Apple Health", "Apple Fitness", "Nutrition", "Prescriptions"]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            VStack {
                
                HStack {
                    Text("Select Your Services")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading)
                    Spacer()
                    // Profile icon
                    Button(action: {
                        showProfile.toggle()
                    }) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color.mhaPurple)
                    }
                    .padding(.trailing)
                }
                .padding(.top, 20)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(services, id: \.self) { service in
                        ServiceButton(service: service, isChecked: selectedServices.contains(service)) {
                            toggleSelection(for: service)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    isLoggedIn = true;
                    
                }) {
                    Text("Continue")
                        .frame(width: 200, height: 50)
                        .background(Color.mhaPurple)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .cornerRadius(25)
                }
                .padding(.bottom, 30)
            }
            .onAppear {
                if !hasShownAlert {
                    showAlert = true
                    hasShownAlert = true
                }
            }
            /*
            .alert("Do you want to enable Face ID?", isPresented: $showAlert) {
                Button("Yes") {
                    enableFaceID()
                    showAlert = false
                }
                Button("No", role: .cancel) {
                    disableFaceID()
                    showAlert = false
                }
            }
            */
            .background(colorScheme == .dark ? Color.black : Color.white)
            .navigationBarHidden(true)
            .overlay(
                Group {
                    if showProfile {
                        UserProfileView(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp, userName: userName, userEmail: userEmail, showProfile: $showProfile )
                    }
                }
            )
        }
    }
    
    private func toggleSelection(for service: String) {
        if selectedServices.contains(service) {
            selectedServices.remove(service)
        } else {
            selectedServices.insert(service)
        }
    }
    /*
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
    */
}

struct ServiceButton: View {
    var service: String
    var isChecked: Bool
    var action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: isChecked ? "checkmark.circle":"circle")
                        .fixedSize()
                        .background(Circle().fill(isChecked ? Color.mhaGreen : Color.clear))
                        .foregroundColor(colorScheme == .dark ? .white : isChecked ? .white : .gray)
                        .frame(width: 20, height: 20)
                        .offset(x:15)
                        .offset(y:20)
                    
                        
                    Spacer()
                }
                
                
                Image(service) //custom icons
                    .resizable()
                    .frame(width: 75, height: 75)
                    .shadow(radius: 1)
                
                Text(service)
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Spacer()
                Spacer()
            }
            .frame(width: 160, height: 160)
            .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
            .cornerRadius(30)
            .shadow(radius: 1)
        }
    }
}

struct ServicesView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isLoggedIn: Bool = false
        @State var hasSignedUp: Bool = false
        @State var showAlert: Bool = true
        ServicesView(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp, showAlert: $showAlert)
    }
}
