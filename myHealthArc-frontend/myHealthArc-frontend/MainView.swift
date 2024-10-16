 //
//  MainView.swift
//  myHealthArc-frontend
//
//  Created by Shahir Ali on 10/16/24.
//

import SwiftUI

struct MainView: View {
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
    ContentView()
}
