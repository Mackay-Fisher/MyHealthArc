//
//  ServicesView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/17/24.
//
import SwiftUI
import LocalAuthentication
import SwiftKeychainWrapper

struct ServicesView: View {
    @Binding var isLoggedIn: Bool
    @Binding var hasSignedUp: Bool
    @StateObject private var servicesViewModel = ServicesViewModel.shared
    
    @AppStorage("hasShownAlert") var hasShownAlert = false
    @Binding var showAlert: Bool

    @Environment(\.colorScheme) var colorScheme
    @State private var userName: String = "User Name"
    @State private var userEmail: String = "user@example.com"
    @State private var showProfile: Bool = false
    
    var services = ["Apple Health", "Apple Fitness", "Nutrition", "Prescriptions"]
    private let userHash = KeychainWrapper.standard.string(forKey: "userHash") ?? "exampleUserHash"
    private let baseURL = "\(AppConfig.baseURL)"

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Select Your Services")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading)
                    Spacer()
                    Button(action: {
                        showProfile.toggle()
                    }) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color.mhaPurple)
                    }
                    .padding(.trailing)
                }
                .padding(.top, 20)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(services, id: \.self) { service in
                        ServiceButton(
                            service: service,
                            isChecked: servicesViewModel.selectedServices[service] ?? false
                        ) {
                            toggleSelection(for: service)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    Task {
                        await updateAllServicesAsync()
                        isLoggedIn = true
                    }
                }) {
                    Text("Continue")
                        .frame(width: 200, height: 50)
                        .background(Color.mhaPurple)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .cornerRadius(25)
                }
                .padding(.bottom, 30)
            }
            .onAppear {
                if !hasShownAlert {
                    showAlert = true
                    hasShownAlert = true
                }
                fetchServices()
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
            .navigationBarHidden(true)
            .overlay(
                Group {
                    if showProfile {
                        UserProfileView(
                            isLoggedIn: $isLoggedIn,
                            hasSignedUp: $hasSignedUp,
                            userName: userName,
                            userEmail: userEmail,
                            showProfile: $showProfile
                        )
                    }
                }
            )
        }
    }
    
    private func toggleSelection(for service: String) {
        servicesViewModel.selectedServices[service] = !(servicesViewModel.selectedServices[service] ?? false)
    }
    
    private func fetchServices() {
        guard let url = URL(string: "\(baseURL)/user-services/fetch?userHash=\(userHash)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to fetch services: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ServiceResponse.self, from: data)
                DispatchQueue.main.async {
                    servicesViewModel.selectedServices = response.selectedServices
                }
            } catch {
                print("Failed to decode services: \(error.localizedDescription)")
                // Initialize default selections if fetch fails
                DispatchQueue.main.async {
                    services.forEach { service in
                        servicesViewModel.selectedServices[service] = false
                    }
                }
            }
        }.resume()
    }
    
    private func updateAllServicesAsync() async {
        guard let url = URL(string: "\(baseURL)/user-services/update") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ServiceRequest(
            userHash: userHash,
            selectedServices: servicesViewModel.selectedServices,
            isFaceIDEnabled: false
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Services updated successfully")
            } else {
                print("Failed to update services: \(response)")
            }
        } catch {
            print("Failed to update services: \(error.localizedDescription)")
        }
    }
}

struct ServiceButton: View {
    var service: String
    var isChecked: Bool
    var action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: isChecked ? "checkmark.circle":"circle")
                        .fixedSize()
                        .background(Circle().fill(isChecked ? Color.mhaGreen : Color.clear))
                        .foregroundColor(colorScheme == .dark ? .white : isChecked ? .white : .gray)
                        .frame(width: 20, height: 20)
                        .offset(x:15)
                        .offset(y:20)
                    
                    Spacer()
                }
                
                Image(service) //custom icons
                    .resizable()
                    .frame(width: 75, height: 75)
                    .shadow(radius: 1)
                
                Text(service)
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Spacer()
                Spacer()
            }
            .frame(width: 160, height: 160)
            .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
            .cornerRadius(30)
            .shadow(radius: 1)
        }
    }
}

struct ServicesView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isLoggedIn: Bool = false
        @State var hasSignedUp: Bool = false
        @State var showAlert: Bool = true
        ServicesView(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp, showAlert: $showAlert)
    }
}
