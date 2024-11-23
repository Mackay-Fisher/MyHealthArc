//
//  SignUpView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/17/24.
//
//TODO: need to add checks to ensure the information being entered is of correct input type

import SwiftUI

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
    
    @Binding var isLoggedIn: Bool
    @Binding var hasSignedUp: Bool
    
    let genderOptions = ["Male", "Female"]
        
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack{
                Form {
                    Section(header: Text("Personal Information")) {
                        TextField("Name", text: $name)
                            .textContentType(.name)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                            .textContentType(.newPassword)
                        SecureField("Re-Enter Password", text: $password2)
                            .textContentType(.newPassword)
                        TextField("Age", text: $age)
                            .keyboardType(.numberPad)
                            
                        // Gender Selection
                        Picker("Gender", selection: $gender) {
                            ForEach(genderOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        
                        // Height Input
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
                        
                        // Weight Input
                        HStack {
                            TextField("Weight", text: $weight)
                                .keyboardType(.decimalPad)
                            Text("lbs")
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
        var request = URLRequest(url: URL(string: "http://localhost:8080/users/signup")!)
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
                    }
                }
            }
        }.resume()
    }
    
    private var formIsValid: Bool {
        let heightFeetValid = Int(heightFeet) ?? 0 > 0
        let heightInchesValid = (Int(heightInches) ?? 0) >= 0 && (Int(heightInches) ?? 0) < 12
        let weightValid = Double(weight) ?? 0 > 0
        
        return !name.isEmpty &&
               !email.isEmpty &&
               !password.isEmpty &&
               !age.isEmpty &&
               acceptedTerms &&
               ageVerified &&
               heightFeetValid &&
               heightInchesValid &&
               weightValid
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isLoggedIn: Bool = false
        @State var hasSignedUp: Bool = false
        SignUpView(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp)
    }
}

