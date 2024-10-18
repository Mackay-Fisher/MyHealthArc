//
//  loginView.swift
//  myHealthArc-frontend
//
//  Created by Anjali Hole on 10/9/24.
//

import SwiftUI




struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @Binding var isLoggedIn: Bool
    
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
                    // Login logic and navigation trigger
                    if !username.isEmpty && !password.isEmpty {
                        isLoggedIn = true
                    }
                    print("Username: \(username), Password: \(password)")
                }
                .frame(width: 100, height: 50)
                .background(username.isEmpty || password.isEmpty ? Color.gray : Color.mhaPurple)
                .cornerRadius(50)
                .foregroundColor(.white)
                .padding(.top)
                .disabled(username.isEmpty || password.isEmpty)
            }
            
            /*.navigationDestination(isPresented: $isLoggedIn) {
                    View() // Destination view
            }*/
            .padding()
       //}
    }
}

#Preview {

    @Previewable @State var isLoggedIn: Bool = false
    LoginView(isLoggedIn: $isLoggedIn)
        
}
