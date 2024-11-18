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
            SettingsView(isLoggedIn: $isLoggedIn,hasSignedUp: $hasSignedUp)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
            //filler atm cuz 2 tabs looks dumb
            EditProfilePage()
                .tabItem {
                    //TODO: figure out why this is filled in
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Profile")
            }
            // Temporary Placement
            MacrosTrackingView()
                .tabItem {
                    Image(systemName: "chart.pie")
                    Text("Macros")
                }
            /*MedicationsView()
                .tabItem {
                    Image(systemName: "pills")
                    Text("Medications")
            }
            NutritionView()
                .tabItem {
                    Image(systemName: "carrot")
                    Text("Nutrition")
            }*/
            
            /*ServicesView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Image(systemName: "heart")
                    Text("Services")
                }
            */
            
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

