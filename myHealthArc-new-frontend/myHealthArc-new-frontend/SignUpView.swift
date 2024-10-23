//
//  SignUpView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/17/24.
//
//TODO: need to add checks to ensure the information being entered is of correct input type
//TODO: figure out how to store info
import SwiftUI

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
    @Binding var isLoggedIn: Bool
    @Binding var hasSignedUp: Bool
    
        
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack{
                Form {
                    //getting inputs
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
                        // Button to show DatePicker
                        Button(action: {
                            showDatePicker.toggle()
                        }) {
                            HStack {
                                Text("Date of Birth")
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                Spacer()
                                Text(dob, style: .date) // Display the selected date
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Show DatePicker conditionally
                        if showDatePicker {
                            DatePicker("Date of Birth", selection: $dob, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                        }
                        
                    }
                    //age verification
                    HStack {
                        Image(systemName: ageVerified ? "checkmark.square" : "square")
                            .foregroundColor(ageVerified ? Color.mhaGreen : .gray) // Change color based on acceptance
                            .onTapGesture {
                                ageVerified.toggle()
                            }
                        Text("I confirm I am above 18 years of age")
                    }
                    //terms and conditions verification
                    Section {
                        HStack {
                            Image(systemName: acceptedTerms ? "checkmark.square" : "square")
                                .foregroundColor(acceptedTerms ? Color.mhaGreen : .gray) // Change color based on acceptance
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
                NavigationLink(destination: ServicesView()){
                    Button(action: signUp) {
                        Text("Sign Up")
                            .frame(width: 200, height: 30)
                            .foregroundColor(.white)
                            .padding()
                            .background(formIsValid ? Color.mhaPurple : Color.gray)
                            .cornerRadius(50)
                    }
                    .disabled(!formIsValid)
                    .background(Color.clear)
                }
            }
            .background(colorScheme == .dark ? Color.black : Color.lightbackground)
            .navigationTitle("Sign Up")
        }
    }
    
    private func signUp() {
        // Handle sign up action
        print("User Signed Up!")
        hasSignedUp = true
        
    }
    
    private var formIsValid: Bool {
        return !name.isEmpty && !email.isEmpty && !password.isEmpty && !age.isEmpty && acceptedTerms
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        // @Previewable 
        @State var isLoggedIn: Bool = false
        @State var hasSignedUp: Bool = false
        SignUpView(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp )
    }
}
