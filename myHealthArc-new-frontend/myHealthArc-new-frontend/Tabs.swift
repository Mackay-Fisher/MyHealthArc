//
//  Tabs.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/17/24.
//

import SwiftUI

struct Tabs: View {
    @Binding var isLoggedIn: Bool
    @Binding var hasSignedUp: Bool
    var body: some View {
        
        TabView {
            ContentView(isLoggedIn: $isLoggedIn,hasSignedUp: $hasSignedUp)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
            }
            
            MacrosTrackingView()
                .tabItem {
                    Image(systemName: "chart.pie")
                    Text("Macros")
                }
            RecipesView()
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text("Recipes")
                }
            GoalsView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Goals")
                }
//            SettingsView(isLoggedIn: $isLoggedIn,hasSignedUp: $hasSignedUp)
//                .tabItem {
//                    Image(systemName: "gear")
//                    Text("Settings")
//                }
            
        }
    }
}

struct Tabs_Previews: PreviewProvider {
    static var previews: some View {
        // @Previewable
        @State var isLoggedIn: Bool = false
        @State var hasSignedUp: Bool = false
        Tabs(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp)
    }
}

