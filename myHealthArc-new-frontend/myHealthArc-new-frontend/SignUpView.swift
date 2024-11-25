//
//  SignUpView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/17/24.
//

import SwiftUI
import SwiftKeychainWrapper

struct UserDTO: Codable {
    var fullName: String
    var email: String
    var password: String
    var gender: String
    var height: Int
    var weight: Double
}

struct User: Codable {
    var id: UUID?
    var fullName: String
    var email: String
    var passwordHash: String
    var userHash: String
}

struct SignUpView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var password2: String = ""
    @State private var age: String = ""
    @State private var dob: Date = Date()
    @State private var acceptedTerms: Bool = false
    @State private var ageVerified: Bool = false
    @State private var showDatePicker: Bool = false
    @State private var showAlert: Bool = true
    @State private var navigateToServicesView: Bool = false
    
    // New fields
    @State private var gender: String = "Male"
    @State private var heightFeet: String = ""
    @State private var heightInches: String = ""
    @State private var weight: String = ""
    
    // Constants for validation
    private let minHeightFeet = 3 // 3 feet
    private let maxHeightFeet = 8 // 8 feet
    private let minWeight = 70.0 // 70 pounds
    private let maxWeight = 700.0 // 700 pounds
    
    @Binding var isLoggedIn: Bool
    @Binding var hasSignedUp: Bool
    
    let genderOptions = ["Male", "Female"]
        
    @Environment(\.colorScheme) var colorScheme
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private var passwordsMatch: Bool {
        return password == password2 && !password.isEmpty
    }
    
    private var heightIsValid: Bool {
        let feet = Int(heightFeet) ?? 0
        let inches = Int(heightInches) ?? 0
        return feet >= minHeightFeet &&
               feet <= maxHeightFeet &&
               inches >= 0 &&
               inches < 12
    }
    
    private var weightIsValid: Bool {
        let weightValue = Double(weight) ?? 0
        return weightValue >= minWeight && weightValue <= maxWeight
    }
    
    private var heightErrorMessage: String {
        if heightFeet.isEmpty || heightInches.isEmpty {
            return "Height is required"
        }
        let feet = Int(heightFeet) ?? 0
        let inches = Int(heightInches) ?? 0
        
        if feet < minHeightFeet || feet > maxHeightFeet {
            return "Height must be between \(minHeightFeet) and \(maxHeightFeet) feet"
        }
        if inches < 0 || inches >= 12 {
            return "Inches must be between 0 and 11"
        }
        return ""
    }
    
    private var weightErrorMessage: String {
        if weight.isEmpty {
            return "Weight is required"
        }
        let weightValue = Double(weight) ?? 0
        if weightValue < minWeight {
            return "Weight must be at least \(Int(minWeight)) pounds"
        }
        if weightValue > maxWeight {
            return "Weight must be less than \(Int(maxWeight)) pounds"
        }
        return ""
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Personal Information")) {
                        TextField("Name", text: $name)
                            .textContentType(.name)
                        
                        VStack(alignment: .leading) {
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                            
                            if !email.isEmpty && !isValidEmail(email) {
                                Text("Please enter a valid email address")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            SecureField("Password", text: $password)
                                .textContentType(.newPassword)
                            SecureField("Re-Enter Password", text: $password2)
                                .textContentType(.newPassword)
                            
                            if !password.isEmpty && !password2.isEmpty && !passwordsMatch {
                                Text("Passwords do not match")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        TextField("Age", text: $age)
                            .keyboardType(.numberPad)
                            
                        // Gender Selection
                        Picker("Gender", selection: $gender) {
                            ForEach(genderOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        
                        // Height Input with Validation
                        VStack(alignment: .leading) {
                            HStack {
                                TextField("Feet", text: $heightFeet)
                                    .keyboardType(.numberPad)
                                    .frame(width: 50)
                                Text("ft")
                                TextField("Inches", text: $heightInches)
                                    .keyboardType(.numberPad)
                                    .frame(width: 50)
                                Text("in")
                            }
                            
                            if !heightFeet.isEmpty && !heightInches.isEmpty && !heightIsValid {
                                Text(heightErrorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Weight Input with Validation
                        VStack(alignment: .leading) {
                            HStack {
                                TextField("Weight", text: $weight)
                                    .keyboardType(.decimalPad)
                                Text("lbs")
                            }
                            
                            if !weight.isEmpty && !weightIsValid {
                                Text(weightErrorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                            
                        Button(action: {
                            showDatePicker.toggle()
                        }) {
                            HStack {
                                Text("Date of Birth")
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                Spacer()
                                Text(dob, style: .date)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if showDatePicker {
                            DatePicker("", selection: $dob, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                        }
                    }
                    
                    HStack {
                        Image(systemName: ageVerified ? "checkmark.square" : "square")
                            .foregroundColor(ageVerified ? Color.mhaGreen : .gray)
                            .onTapGesture {
                                ageVerified.toggle()
                            }
                        Text("I confirm I am above 18 years of age")
                    }
                    
                    Section {
                        HStack {
                            Image(systemName: acceptedTerms ? "checkmark.square" : "square")
                                .foregroundColor(acceptedTerms ? Color.mhaGreen : .gray)
                                .onTapGesture {
                                    acceptedTerms.toggle()
                                }
                            NavigationLink(destination: TermsAndConditionsView(acceptedTerms: $acceptedTerms)) {
                                Text("I have read the Terms & Conditions")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                if formIsValid {
                    NavigationLink(destination: ServicesView(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp, showAlert: $showAlert), isActive: $navigateToServicesView) {
                        EmptyView()
                    }
                    Button(action: {
                        signUp()
                    }) {
                        Text("Sign Up")
                            .frame(width: 200, height: 30)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.mhaPurple)
                            .cornerRadius(50)
                    }
                } else {
                    Text("Sign Up")
                        .frame(width: 200, height: 30)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(50)
                }
            }
            .background(colorScheme == .dark ? Color.black : Color.lightbackground)
            .navigationTitle("Sign Up")
        }
    }
    
    private func signUp() {
        var request = URLRequest(url: URL(string: "\(AppConfig.baseURL)/users/signup")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let totalHeightInches = (Int(heightFeet) ?? 0) * 12 + (Int(heightInches) ?? 0)
        let userDTO = UserDTO(fullName: name, email: email, password: password, gender: gender, height: totalHeightInches, weight: Double(weight) ?? 0.0)
        guard let httpBody = try? JSONEncoder().encode(userDTO) else { return }
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let user = try? JSONDecoder().decode(User.self, from: data) {
                    DispatchQueue.main.async {
                        navigateToServicesView = true
                        KeychainWrapper.standard.set(user.userHash, forKey: "userHash")
                        print("KEYCHAIN DEBUG - userHash saved: \(user.userHash)")
                    }
                }
            }
        }.resume()
    }
    
    private var formIsValid: Bool {
        let emailValid = isValidEmail(email)
        
        return !name.isEmpty &&
               !email.isEmpty &&
               emailValid &&
               !password.isEmpty &&
               passwordsMatch &&
               !age.isEmpty &&
               acceptedTerms &&
               ageVerified &&
               heightIsValid &&
               weightIsValid
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isLoggedIn: Bool = false
        @State var hasSignedUp: Bool = false
        SignUpView(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp)
    }
}

