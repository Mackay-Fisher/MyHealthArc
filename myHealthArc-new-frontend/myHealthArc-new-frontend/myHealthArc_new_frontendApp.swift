//
//  myHealthArc_new_frontendApp.swift
//  myHealthArc-new-frontend
//
//  Created by Vancura, Christiana Elaine on 10/17/24.
//
//This file is just navigating between the initial files, so login, or the view where navigation options are present (tabs)
import SwiftUI

@main
struct myHealthArc_new_frontendApp: App {
    @State private var isLoggedIn = false
        
        var body: some Scene {
            WindowGroup {
                if isLoggedIn {
                    Tabs()
                } else {
                    LoginView(isLoggedIn: $isLoggedIn)
                }
            }
        }
}
