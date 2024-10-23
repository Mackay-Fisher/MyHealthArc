//
//  Tabs.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/17/24.
//

import SwiftUI

struct Tabs: View {
    @State private var isLoggedIn = false
    var body: some View {
        
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            ServicesView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Image(systemName: "heart")
                    Text("Services")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct Tabs_Previews: PreviewProvider {
    static var previews: some View {
        // @Previewable
        Tabs()
    }
}

