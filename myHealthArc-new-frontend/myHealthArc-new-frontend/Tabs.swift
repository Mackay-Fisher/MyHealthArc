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
            MedicationsView()
                .tabItem {
                    Image(systemName: "pills")
                    Text("Medications")
            }
            NutritionView()
                .tabItem {
                    Image(systemName: "carrot")
                    Text("Nutrition")
            }
            //TODO: add medication and nutrition here
            /*ServicesView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Image(systemName: "heart")
                    Text("Services")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }*/
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

