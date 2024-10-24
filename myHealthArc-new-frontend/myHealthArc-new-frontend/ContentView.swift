//this is the dashboard page
import SwiftUI

struct ContentView: View {
    @State private var showSettings: Bool = false // Toggle settings visibility
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var isLoggedIn: Bool
    @Binding var hasSignedUp: Bool

    var body: some View {
        ZStack {
            // Main Content View
            VStack {
                // Header with title and profile icon
                HStack {
                    Text("myHealthData")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut) {
                            showSettings.toggle() // Toggle settings view
                        }
                    }) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color.mhaPurple)
                    }
                    .padding()
                }

                // Widgets Area
                ScrollView {
                    VStack(spacing: 20) {
                        WidgetView(title: "Apple Health", detail: "Sleep: 8 hours")
                        WidgetView(title: "Apple Fitness", detail: "Steps: 2,000")
                        WidgetView(title: "Prescription Checker", detail: "ibuprofen vs aspirin")
                        WidgetView(title: "Nutrition Tracker", detail: "Macros for food")
                    }
                    .padding()
                    .shadow(radius: 0.5)
                }
            }
            .background(colorScheme == .dark ? Color(.systemBackground) : Color.lightbackground)
            .navigationBarHidden(true)

            // Slide-out Settings View
            if showSettings {
                Color.black.opacity(0.4) // Dimmed background when settings is open
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            showSettings = false // Close settings when clicking outside
                        }
                    }

                SettingsView(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp)
                    .frame(width: UIScreen.main.bounds.width * 0.8) // 80% of screen width
                    .background(colorScheme == .dark ? Color.mhaGray : Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .offset(x: showSettings ? 0 : UIScreen.main.bounds.width) // Slide-in effect
                    .animation(.easeInOut, value: showSettings)
                    .gesture(
                        DragGesture().onEnded { value in
                            if value.translation.width > 100 { // Detect swipe to close
                                withAnimation(.easeInOut) {
                                    showSettings = false
                                }
                            }
                        }
                    )
            }
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
