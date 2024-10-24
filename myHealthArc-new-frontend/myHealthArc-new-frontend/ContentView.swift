//this is the dashboard page
import SwiftUI

import SwiftUI

struct ContentView: View {
    @State private var showSettings: Bool = false
    @Binding var isLoggedIn: Bool
    @Binding var hasSignedUp: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Widgets area
                    WidgetView(title: "Apple Health", detail: "Sleep: 8 hours")
                    WidgetView(title: "Apple Fitness", detail: "Steps: 2,000")

                    NavigationLink(destination: MedicationsView()) {
                        WidgetView(title: "Medication Checker", detail: "Check for drug interactions")
                    }

                    NutritionWidgetView()
                }
                .padding()
                
            }
            .navigationTitle("myHealthData")
            .background(colorScheme == .dark ? Color(.systemBackground) : Color.lightbackground)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    SettingsButton(showSettings: $showSettings)
                }
            }
        }
        .withSettingsOverlay(
            showSettings: $showSettings,
            isLoggedIn: $isLoggedIn,
            hasSignedUp: $hasSignedUp
        )
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
                .padding(.top)
            Divider()
                .frame(width: UIScreen.main.bounds.width * 0.8)
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
    @Binding var isLoggedIn: Bool
    @Binding var hasSignedUp: Bool
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
            Divider().padding(.horizontal)

            // Settings View
            SettingsView(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp)


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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isLoggedIn: Bool = false
        @State var hasSignedUp: Bool = false
        ContentView(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp)
    }
}
