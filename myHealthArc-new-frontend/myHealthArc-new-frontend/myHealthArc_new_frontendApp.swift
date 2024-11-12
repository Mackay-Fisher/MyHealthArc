//
//  myHealthArc_new_frontendApp.swift
//  myHealthArc-new-frontend
//
//  Created by Vancura, Christiana Elaine on 10/17/24.
//
//This file is just navigating between the initial files, so login, or the view where navigation options are present (tabs)
import SwiftUI
import LocalAuthentication
import SwiftKeychainWrapper

//NOTE: can just use this as is across all folders
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
    // Define standard colors
    static let mhaPurple = Color(hex: "#C197D2")
    static let mhaGreen = Color(hex: "#5EB229")
    static let mhaGray = Color(hex: "#292828")
    static let lightbackground = Color(hex: "#f2f2f2")
    
}

@main
struct myHealthArc_new_frontendApp: App {
    @State private var isLoggedIn = false
    @State private var hasSignedUp = false
    @State private var showAlert = true
        
        var body: some Scene {
            WindowGroup {
                if isLoggedIn {
                    Tabs(isLoggedIn: $isLoggedIn , hasSignedUp: $hasSignedUp)
                }
                else if hasSignedUp {
                    ServicesView(isLoggedIn: $isLoggedIn , hasSignedUp: $hasSignedUp, showAlert: $showAlert)
                }
                else {
                    //LoginView(isLoggedIn: $isLoggedIn)
                    AppOpenScreen(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp)
                }
            }
        }

    private func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Log in with FaceID") { success, authenticationError in
                if success {
                    DispatchQueue.main.async {
                        if let userHash = KeychainWrapper.standard.string(forKey: "userHash") {
                            Task {
                                do {
                                    let user = try await fetchUserDetails(userHash: userHash)
                                    isLoggedIn = true
                                } catch {
                                }
                            }
                        }
                    }
                } else {
                }
            }
        } else {
        }
    }

    private func fetchUserDetails(userHash: String) async throws -> User {
        guard let url = URL(string: "http://localhost:8080/users/\(userHash)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let user = try JSONDecoder().decode(User.self, from: data)
        return user
    }
}
