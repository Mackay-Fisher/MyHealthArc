//
//  TermsAndConditionsView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/17/24.
//
import SwiftUI

/*struct TermsAndConditionsView: View {
    @Binding var acceptedTerms: Bool
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Terms & Conditions for myHealthArc")
                    .font(.title)
                    .bold()
                    .padding()
                
                Group {
                    Text("1. Introduction")
                        .font(.headline)
                    Text("Welcome to myHealthArc. By accessing or using the myHealthArc app, you agree to comply with and be bound by these Terms and Conditions. Please read them carefully.")
                    
                    Text("2. User Responsibility")
                        .font(.headline)
                    Text("When creating an account, users are responsible for ensuring that all information entered is accurate and up-to-date. myHealthArc is not responsible for any issues that arise due to incorrect or outdated user-provided information.")
                    
                    Text("3. No Medical Advice")
                        .font(.headline)
                    Text("myHealthArc is designed to aggregate data from various sources to help users better understand their overall health. However, this app is not intended to provide medical advice, diagnosis, or treatment. The creators of myHealthArc are not medical professionals. Information provided by the app should not be treated as a substitute for professional medical advice. Always seek the guidance of your healthcare provider with any questions regarding a medical condition or treatment.")
                    
                    Text("4. Data Integration")
                        .font(.headline)
                    Text("myHealthArc integrates data from various third-party sources, including APIs. While we aim to provide accurate and up-to-date information, myHealthArc cannot guarantee the completeness or reliability of data from these external sources.")
                    
                    Text("5. Privacy and Data Security")
                        .font(.headline)
                    Text("User privacy and data security are of utmost importance. myHealthArc uses secure encryption methods to protect user data. Users are encouraged to maintain the confidentiality of their account information and password.")
                }
                
                Group {
                    Text("6. Limitation of Liability")
                        .font(.headline)
                    Text("myHealthArc is not liable for any direct, indirect, incidental, or consequential damages arising from the use or inability to use the app, including but not limited to any errors in data, delays, or inaccuracies from third-party services.")
                    
                    Text("7. Changes to Terms and Conditions")
                        .font(.headline)
                    Text("myHealthArc reserves the right to modify these Terms and Conditions at any time. Users will be notified of significant changes, and continued use of the app after such modifications will signify acceptance of the revised terms.")
                    
                    Text("8. Contact Information")
                        .font(.headline)
                    Text("If you have any questions about these Terms and Conditions, please contact us at anjali_hole@tamu.edu.")
                }
                
                Text("By using the myHealthArc app, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.")
                    .padding(.bottom)
                Button(action: {
                    acceptedTerms = true // Automatically check the terms
                }) {
                    Text("Accept")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Terms & Conditions")
    }
}
struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TermsAndConditionsView(acceptedTerms: .constant(false)) // Preview with a default value
        }
    }
}*/
import SwiftUI

struct TermsAndConditionsView: View {
    @Binding var acceptedTerms: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {

                
                Group {
                    Text("1. Introduction")
                        .font(.headline)
                    Text("Welcome to myHealthArc. By accessing or using the myHealthArc app, you agree to comply with and be bound by these Terms and Conditions. Please read them carefully.")
                    
                    Text("2. User Responsibility")
                        .font(.headline)
                    Text("When creating an account, users are responsible for ensuring that all information entered is accurate and up-to-date. myHealthArc is not responsible for any issues that arise due to incorrect or outdated user-provided information.")
                    
                    Text("3. No Medical Advice")
                        .font(.headline)
                    Text("myHealthArc is designed to aggregate data from various sources to help users better understand their overall health. However, this app is not intended to provide medical advice, diagnosis, or treatment. The creators of myHealthArc are not medical professionals. Information provided by the app should not be treated as a substitute for professional medical advice. Always seek the guidance of your healthcare provider with any questions regarding a medical condition or treatment.")
                    
                    Text("4. Data Integration")
                        .font(.headline)
                    Text("myHealthArc integrates data from various third-party sources, including APIs. While we aim to provide accurate and up-to-date information, myHealthArc cannot guarantee the completeness or reliability of data from these external sources.")
                    
                    Text("5. Privacy and Data Security")
                        .font(.headline)
                    Text("User privacy and data security are of utmost importance. myHealthArc uses secure encryption methods to protect user data. Users are encouraged to maintain the confidentiality of their account information and password.")
                }
                
                Group {
                    Text("6. Limitation of Liability")
                        .font(.headline)
                    Text("myHealthArc is not liable for any direct, indirect, incidental, or consequential damages arising from the use or inability to use the app, including but not limited to any errors in data, delays, or inaccuracies from third-party services.")
                    
                    Text("7. Changes to Terms and Conditions")
                        .font(.headline)
                    Text("myHealthArc reserves the right to modify these Terms and Conditions at any time. Users will be notified of significant changes, and continued use of the app after such modifications will signify acceptance of the revised terms.")
                    
                    Text("8. Contact Information")
                        .font(.headline)
                    Text("If you have any questions about these Terms and Conditions, please contact us at anjali_hole@tamu.edu.")
                }
                
                Text("By using the myHealthArc app, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.")
                    .padding(.bottom)
                
                Button(action: {
                    acceptedTerms = true // Automatically check the terms
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Accept")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#C197D2"))
                        .foregroundColor(.white)
                        .cornerRadius(50)
                    
                    
                    
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Terms & Conditions")
    }
}

struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TermsAndConditionsView(acceptedTerms: .constant(false)) // Preview with a default value
        }
    }
}

