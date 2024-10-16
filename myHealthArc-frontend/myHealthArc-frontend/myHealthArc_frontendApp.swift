//
//  myHealthArc_frontendApp.swift
//  myHealthArc-frontend
//
//  Created by Anjali Hole on 10/9/24.
//

import SwiftUI

@main
struct myHealthArc_frontendApp: App {
    var body: some Scene {
        WindowGroup {
            LoginView(isLoggedIn: .constant(false))
        }
    }
}
