//
//  myHealthArc_frontendApp.swift
//  myHealthArc-frontend
//
//  Created by Anjali Hole on 10/9/24.
//
import SwiftUI

@main
struct myHealthArc_frontendApp: App {
    // Declare the state variable outside of the body
    @State private var isLoggedIn: Bool = false

    var body: some Scene {
        WindowGroup {
            
            if isLoggedIn {
                
                MainView()
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}

