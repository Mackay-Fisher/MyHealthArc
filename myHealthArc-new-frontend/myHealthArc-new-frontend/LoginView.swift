//
//  loginView.swift
//  myHealthArc-frontend
//
//  Created by Anjali Hole on 10/9/24.
//

import SwiftUI
import LocalAuthentication
import SwiftKeychainWrapper

struct LoginDTO: Codable {
    var email: String
    var password: String
}

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @Binding var isLoggedIn: Bool
    @State private var showFaceIDPrompt: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        //NavigationStack {
            VStack {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                
                Text("myHealthArc")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.top, -20)
                    .padding(.bottom, 30)
                
                TextField("Username", text: $username)
                    .font(.system(size: 18))
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 0.5)
                    )
                    .padding(.horizontal)
                    .frame(width: 250, height: 50)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 5)
                
                SecureField("Password", text: $password)
                    .font(.system(size: 18))
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 0.5)
                    )
                    .padding(.horizontal)
                    .frame(width: 250, height: 50)
                    .multilineTextAlignment(.center)
                
                    
                Button("Login") {
                    login()
                }
                .frame(width: 100, height: 50)
                .background(username.isEmpty || password.isEmpty ? Color.gray : Color.mhaPurple)
                .cornerRadius(50)
                .foregroundColor(.white)
                .padding(.top)
                .disabled(username.isEmpty || password.isEmpty)
            }
            /*
            .onAppear {
                if KeychainWrapper.standard.bool(forKey: "isFaceIDEnabled") == true {
                    authenticateWithFaceID()
                }
            }
            */
            
            /*.navigationDestination(isPresented: $isLoggedIn) {
                    View() // Destination view
            }*/
            .padding()
       //}
    }

    private func login() {
        var request = URLRequest(url: URL(string: "http://localhost:8080/users/login")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let loginDTO = LoginDTO(email: username, password: password)
        guard let httpBody = try? JSONEncoder().encode(loginDTO) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let user = try? JSONDecoder().decode(User.self, from: data) {
                    DispatchQueue.main.async {
                        isLoggedIn = true
                        KeychainWrapper.standard.set(user.userHash, forKey: "userHash")
                        print("KEYCHAIN DEBUG - userHash saved: \(user.userHash)")
                    }
                } else {
                    DispatchQueue.main.async {
                        isLoggedIn = false
                    }
                }
            }
        }.resume()
    }

    /*
    private func checkFaceID() {
        if KeychainWrapper.standard.bool(forKey: "isFaceIDEnabled") == true {
            authenticateWithFaceID()
        }
    }

    private func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Log in with FaceID") { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        if let userHash = KeychainWrapper.standard.string(forKey: "userHash") {
                            Task {
                                do {
                                    let user = try await fetchUserDetails(userHash: userHash)
                                    isLoggedIn = true
                                    print("FaceID authentication successful")
                                } catch {
                                    print("Failed to fetch user details: \(error.localizedDescription)")
                                    isLoggedIn = false
                                }
                            }
                        } else {
                            print("KeychainWrapper: Failed to retrieve userHash")
                        }
                    } else {
                        if let error = authenticationError {
                            print("Authentication failed: \(error.localizedDescription)")
                        }
                        isLoggedIn = false
                    }
                }
            }
        } else {
            if let error = error {
                print("Biometrics not available: \(error.localizedDescription)")
            }
            isLoggedIn = false
        }
    }
    */

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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        // @Previewable
        @State var isLoggedIn: Bool = false
        LoginView(isLoggedIn: $isLoggedIn)
    }
}
