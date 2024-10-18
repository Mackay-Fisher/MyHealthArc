//
//  SignUpView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/17/24.
//

import SwiftUI

struct SignUpView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var age: String = ""
    @State private var dob: Date = Date()
    @State private var acceptedTerms: Bool = false
    
    var body: some View {
        NavigationView {
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
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    
                    // Manually adding a label using HStack
                    HStack {
                        Text("Date of Birth")
                        Spacer()
                        DatePicker("", selection: $dob, displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: acceptedTerms ? "checkmark.square" : "square")
                            .foregroundColor(acceptedTerms ? Color(hex:"#5EB229") : .gray) // Change color based on acceptance
                            .onTapGesture {
                                acceptedTerms.toggle()
                            }
                        NavigationLink(destination: TermsAndConditionsView(acceptedTerms: $acceptedTerms)) {
                            Text("I have read the Terms & Conditions")
                                .foregroundColor(.blue)
                        }
                    }
                }

                
                Section {
                    
                }
                
                Section {
                    Button(action: signUp) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(formIsValid ? Color(hex: "#C197D2") : Color.gray)
                            .cornerRadius(50)
                    }
                    .disabled(!formIsValid)
                }
            }
            .navigationTitle("Sign Up")
        }
    }
    
    private func signUp() {
        // Handle sign up action
        print("User Signed Up!")
    }
    
    private var formIsValid: Bool {
        return !name.isEmpty && !email.isEmpty && !password.isEmpty && !age.isEmpty && acceptedTerms
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
