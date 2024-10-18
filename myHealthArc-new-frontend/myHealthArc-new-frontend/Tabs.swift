//
//  Tabs.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/17/24.
//

import SwiftUI

struct Tabs: View {
    var body: some View {
        
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            ServicesView()
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

#Preview {
   Tabs()
}
