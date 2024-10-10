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
    
    var body: some View {
        VStack {
            Image("logo") // Ensure "logo" is the correct name in your assets
                .resizable() // Allows the image to be resized
                .aspectRatio(contentMode: .fit) // Maintain aspect ratio
                .frame(width: 200, height: 200) // Set desired width and height
            
            Text("myHealthArc")
                .font(.largeTitle)
                .padding()
            
            TextField("Username", text: $username)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8) // Optional: Add corner radius for better aesthetics
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8) // Optional: Add corner radius for better aesthetics
            
            Button("Login") {
                // Navigation action to go to the next screen
                // Add navigation logic here
            }
            .frame(width: 200, height: 50)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
