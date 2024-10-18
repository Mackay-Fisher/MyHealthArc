//
//  myHealthArc_new_frontendApp.swift
//  myHealthArc-new-frontend
//
//  Created by Vancura, Christiana Elaine on 10/17/24.
//

import SwiftUI

@main
struct myHealthArc_new_frontendApp: App {
    @State private var isLoggedIn = false
        
        var body: some Scene {
            WindowGroup {
                if isLoggedIn {
                    ContentView() // Replace with the main view of your app
                } else {
                    LoginView(isLoggedIn: $isLoggedIn)
                }
            }
        }
}
