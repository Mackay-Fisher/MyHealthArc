//
//  ContentView.swift
//  myHealthArc-new-frontend
//
//  Created by Vancura, Christiana Elaine on 10/17/24.
//
//this is the dashboard page
import SwiftUI


struct ContentView: View {
    @State private var userName: String = "User Name" // Placeholder for user name
    @State private var userEmail: String = "user@example.com" // Placeholder for user email
    @State private var showProfile: Bool = false // To toggle user profile visibility
    @Environment(\.colorScheme) var colorScheme
    

    var body: some View {
        NavigationView {
            VStack {
                // Header with title and profile icon
                HStack {
                    Text("myHealthData")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                    // Profile icon
                    Button(action: {
                        showProfile.toggle()
                    }) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color.mhaPurple)
                    }
                    .padding()
                }
                
                // Widgets area
                ScrollView {
                    VStack(spacing: 20) {
                        // Placeholder widgets
                        WidgetView(title: "Activity Tracker", detail: "Steps: 10,000")
                        WidgetView(title: "Nutrition Tracker", detail: "Calories: 2,000")
                        WidgetView(title: "Sleep Tracker", detail: "Hours: 8")
                        WidgetView(title: "Medication Reminder", detail: "Next Dose: 2:00 PM")
                    }
                    .padding()
                 
                }
            }
            .background(colorScheme == .dark ? Color(.systemBackground) : Color.lightbackground)
            .navigationBarHidden(false) // Hide the default navigation bar
            .overlay(
                // User Profile Modal
                Group {
                    if showProfile {
                        UserProfileView(userName: userName, userEmail: userEmail, showProfile: $showProfile)
                    }
                }
            )
        }
    }
}

// Widget View for displaying health data
struct WidgetView: View {
    var title: String
    var detail: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .padding()
            Text(detail)
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? Color.mhaGray : Color.white)
        .cornerRadius(25)
    }
}

// User Profile View
struct UserProfileView: View {
    var userName: String
    var userEmail: String
    @Binding var showProfile: Bool
    @Environment(\.colorScheme) var colorScheme

    
    var body: some View {
        VStack {
            HStack {
                Text("User Profile")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    showProfile = false // Close the profile view
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.mhaGreen)
                        .font(.title)
                }
            }
            .padding()
            
            VStack(alignment: .leading) {
                Text("Name: \(userName)")
                    .font(.headline)
                Text("Email: \(userEmail)")
                    .font(.subheadline)
            }
            .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
        .background(colorScheme == .dark ? Color.mhaGray : Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
        .padding()
        .transition(.move(edge: .top)) // Add transition for profile view
    }
}

// Preview for ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
