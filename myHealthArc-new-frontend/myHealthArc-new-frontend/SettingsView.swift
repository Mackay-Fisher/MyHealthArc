//
//  SettingsView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/17/24.
//


//
//  settingsView.swift
//  myHealthArc-frontend
//
//  Created by Anjali Hole on 10/9/24.
//
//TODO: add logout method
import SwiftUI

struct SettingsView: View {
    @State private var appleHealth: Bool = false
    @State private var appleFitness: Bool = false
    @State private var prescription: Bool = false
    @State private var nutrition: Bool = false
    
    @State private var isLoggedIn: Bool = true
    @State private var hasSignedUp: Bool = true

    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Divider()
                    .overlay(colorScheme == .dark ? Color.white : Color.gray)

                
                Text("Toggle Services")
                    .font(.title2)
                    .padding()
                
                Section{
                    Toggle("Apple Health", isOn: $appleHealth)
                        .font(.system(size: 18))
                        .toggleStyle(.switch)
                        .tint(Color.mhaGreen)
                        .padding()
                        .frame(width:300)
                }
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .cornerRadius(20)
                
                Spacer().frame(height: 20)
                
                Section{
                    Toggle("Apple Fitness", isOn: $appleFitness)
                        .font(.system(size: 18))
                        .toggleStyle(.switch)
                        .tint(Color.mhaGreen)
                        .padding()
                        .frame(width:300)
                }
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .cornerRadius(20)
                
                Spacer().frame(height: 20)
                
                Section{
                    Toggle("Prescriptions", isOn: $prescription)
                        .font(.system(size: 18))
                        .toggleStyle(.switch)
                        .tint(Color.mhaGreen)
                        .padding()
                        .frame(width:300)
                }
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .cornerRadius(20)
                
                Spacer().frame(height: 20)
                
                Section{
                    Toggle("Nutrition", isOn: $nutrition)
                        .font(.system(size: 18))
                        .toggleStyle(.switch)
                        .tint(Color.mhaGreen)
                        .padding()
                        .frame(width:300)
                }
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .cornerRadius(20)
                
                Spacer().frame(height: 20)
                
                Divider()
                    .overlay(colorScheme == .dark ? Color.white : Color.gray)
                    
                
                Text("Manage Account")
                    .font(.title2)
                    .padding()

                Section {
                    //TODO: fix the navigation here
                    NavigationLink(destination: EditProfilePage()) {
                        Text("Edit Profile")
                    }
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                }
                .padding()
                .frame(width: 300 , height:50)
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .cornerRadius(20)
                
                Spacer().frame(height: 20)
                
                NavigationLink(destination: AppOpenScreen(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp)){
                    Button("Log Out"){}
                }
                .frame(width: 200, height: 50)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            
        }
        .background(colorScheme == .dark ? Color.black : Color.lightbackground)
    }
    
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // @Previewable
        SettingsView()
    }
}

