//this is the dashboard page
import SwiftUI

// Service View Model
class ServicesViewModel: ObservableObject {
    @Published var selectedServices: [String: Bool] = [:]
    static let shared = ServicesViewModel()
}

struct ContentView: View {
    @State private var showSettings: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var servicesViewModel = ServicesViewModel.shared
    
    @Binding var isLoggedIn: Bool
    @Binding var hasSignedUp: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        Text("myHealthData")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut) {
                                showSettings.toggle()
                            }
                        }) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color.mhaPurple)
                        }
                        .padding()
                    }.padding()
                    
                    // Widgets Area
                    ScrollView {
                        VStack(spacing: 20) {
                            if servicesViewModel.selectedServices["Apple Health"] ?? false {
                                HealthWidget()
                            }
                            
                            if servicesViewModel.selectedServices["Apple Fitness"] ?? false {
                                FitnessWidgetView()
                            }
                            
                            if servicesViewModel.selectedServices["Prescriptions"] ?? false {
                                MedicationWidget()
                            }
                            
                            if servicesViewModel.selectedServices["Nutrition"] ?? false {
                                NutritionWidgetView()
                                WaterWidget()
                            }
                        }
                        .shadow(radius: 0.5)
                    }
                }
                .background(colorScheme == .dark ? Color(.systemBackground) : Color.lightbackground)
                .navigationBarHidden(true)
                
                // Slide-out Settings View
                if showSettings {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                showSettings = false
                            }
                        }
                    
                    SettingsView(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp)
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.7)
                        .background(colorScheme == .dark ? Color.mhaGray : Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .offset(x: showSettings ? 0 : UIScreen.main.bounds.width)
                        .animation(.easeInOut, value: showSettings)
                        .gesture(
                            DragGesture().onEnded { value in
                                if value.translation.width > 100 {
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
                    showProfile = false
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
            
            SettingsView(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
        .background(colorScheme == .dark ? Color.mhaGray : Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
        .padding()
        .transition(.move(edge: .top))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isLoggedIn: Bool = false
        @State var hasSignedUp: Bool = false
        ContentView(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp)
    }
}
