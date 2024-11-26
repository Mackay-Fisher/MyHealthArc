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

struct LoginError: Identifiable {
    let id = UUID()
    let message: String
}

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @Binding var isLoggedIn: Bool
    @State private var showFaceIDPrompt: Bool = false
    @State private var loginError: LoginError?
    @State private var isLoading: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var body: some View {
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
            
            VStack(alignment: .leading, spacing: 5) {
                TextField("Email", text: $username)
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
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                if !username.isEmpty && !isValidEmail(username) {
                    Text("Please enter a valid email address")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 25)
                }
            }
            
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
                .padding(.top, 5)
            
            if isLoading {
                ProgressView()
                    .padding(.top)
            } else {
                Button("Login") {
                    login()
                }
                .frame(width: 170, height: 50)
                .background(formIsValid ? Color.mhaPurple : Color.gray)
                .cornerRadius(50)
                .foregroundColor(.white)
                .padding(.top)
                .disabled(!formIsValid)
            }
            
            if let error = loginError {
                Text(error.message)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 10)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
    
    private var formIsValid: Bool {
        return !username.isEmpty &&
               isValidEmail(username) &&
               !password.isEmpty
    }

    private func login() {
        isLoading = true
        loginError = nil
        
        var request = URLRequest(url: URL(string: "\(AppConfig.baseURL)/users/login")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginDTO = LoginDTO(email: username, password: password)
        guard let httpBody = try? JSONEncoder().encode(loginDTO) else {
            loginError = LoginError(message: "Failed to prepare login request")
            isLoading = false
            return
        }
        
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    loginError = LoginError(message: "Connection error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    loginError = LoginError(message: "Invalid server response")
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    if let data = data,
                       let user = try? JSONDecoder().decode(User.self, from: data) {
                        isLoggedIn = true
                        KeychainWrapper.standard.set(user.userHash, forKey: "userHash")
                        print("KEYCHAIN DEBUG - userHash saved: \(user.userHash)")
                    } else {
                        loginError = LoginError(message: "Failed to process server response")
                    }
                case 401:
                    loginError = LoginError(message: "Invalid email or password")
                case 404:
                    loginError = LoginError(message: "Account not found")
                case 500:
                    loginError = LoginError(message: "Server error. Please try again later")
                default:
                    loginError = LoginError(message: "Login failed: Unknown error")
                }
            }
        }.resume()
    }

    private func fetchUserDetails(userHash: String) async throws -> User {
        guard let url = URL(string: "\(AppConfig.baseURL)/users/\(userHash)") else {
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
        @State var isLoggedIn: Bool = false
        LoginView(isLoggedIn: $isLoggedIn)
    }
}
