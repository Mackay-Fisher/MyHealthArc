//
//  myHealthArc_new_frontendApp.swift
//  myHealthArc-new-frontend
//
//  Created by Vancura, Christiana Elaine on 10/17/24.
//
//This file is just navigating between the initial files, so login, or the view where navigation options are present (tabs)
import SwiftUI

//NOTE: can just use this as is across all folders
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
    }
    // Define standard colors
    static let mhaPurple = Color(hex: "#C197D2")
    static let mhaGreen = Color(hex: "#5EB229")
}

@main
struct myHealthArc_new_frontendApp: App {
    @State private var isLoggedIn = false
        
        var body: some Scene {
            WindowGroup {
                if isLoggedIn {
                    Tabs()
                } else {
                    //LoginView(isLoggedIn: $isLoggedIn)
                    AppOpenScreen(isLoggedIn: $isLoggedIn)
                }
            }
        }
}
