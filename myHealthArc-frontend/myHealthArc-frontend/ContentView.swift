 //
//  ContentView.swift
//  myHealthArc-frontend
//
//  Created by Anjali Hole on 10/9/24.
//

import SwiftUI

struct ContentView: View {
    @State var isLoggedIn = false
    
    var body: some View {
        VStack {
            if isLoggedIn {
                // Filler content for when the user is logged in
                Text("Welcome to MyHealthArc!")
                    .font(.largeTitle)
                    .padding()
                
                Button("Log Out") {
                    isLoggedIn = false // Reset login state for testing
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

