import SwiftUI
import LocalAuthentication
import SwiftKeychainWrapper

struct SettingsView: View {
    //@AppStorage("isFaceIDEnabled") private var isFaceIDEnabled: Bool = false
    @State private var availableServices: [String] = ["Apple Health", "Apple Fitness", "Prescriptions", "Nutrition"]
    @State private var selectedServices: [String: Bool] = [:]
    @Binding var isLoggedIn: Bool
    @Binding var hasSignedUp: Bool
    @Environment(\.colorScheme) var colorScheme

    private let userHash = "exampleUserHash" // Replace this with dynamic userHash later
    private let baseURL = "\(AppConfig.baseURL)"

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

                ForEach(availableServices, id: \.self) { service in
                    Section {
                        Toggle(service, isOn: Binding(
                            get: { selectedServices[service] ?? false },
                            set: { isEnabled in
                                selectedServices[service] = isEnabled
                            }
                        ))
                        .font(.system(size: 18))
                        .toggleStyle(.switch)
                        .tint(Color.mhaGreen)
                        .padding()
                        .frame(width: 300)
                    }
                    .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                    .cornerRadius(20)
                    .padding(.bottom, 20)
                }

                Divider()
                    .overlay(colorScheme == .dark ? Color.white : Color.gray)

                Text("Manage Account")
                    .font(.title2)
                    .padding()

                Section {
                    NavigationLink(destination: EditProfilePage()) {
                        Text("Edit Profile")
                    }
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                }
                .padding()
                .frame(width: 300, height: 50)
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .cornerRadius(20)
                
                Spacer().frame(height: 20)
                /*
                Section {
                    Toggle("Enable FaceID", isOn: $isFaceIDEnabled)
                        .onChange(of: isFaceIDEnabled) { value in
                            if value {
                                enableFaceID()
                            } else {
                                disableFaceID()
                            }
                        }
                        .font(.system(size: 18))
                        .toggleStyle(.switch)
                        .tint(Color.mhaGreen)
                        .padding()
                        .frame(width: 300)
                }
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .cornerRadius(20)

                Spacer().frame(height: 20)
                */
                Button("Logout") {
                    hasSignedUp = false
                    isLoggedIn = false
                    KeychainWrapper.standard.removeObject(forKey: "userHash")
                }
                .fontWeight(.bold)
                .foregroundColor(.red)
                .frame(width: 200, height: 50)
                .padding()
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .cornerRadius(20)
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black : Color.lightbackground)
        .onAppear(perform: fetchServices)
        .onDisappear {
            Task {
                await updateAllServicesAsync()
            }
        }
    }

    // MARK: Fetch User Services
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
                    self.selectedServices = response.selectedServices
                }
            } catch {
                print("Failed to decode services: \(error.localizedDescription)")
            }
        }.resume()
    }

    // MARK: Update All Services (Async)
    private func updateAllServicesAsync() async {
        guard !selectedServices.isEmpty else {
            print("No services selected. Skipping update.")
            return
        }

        guard let url = URL(string: "\(baseURL)/user-services/update") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ServiceRequest(
            userHash: userHash,
            selectedServices: selectedServices,
            isFaceIDEnabled: false // No FaceID in this version
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

// MARK: - Request and Response Models
struct ServiceRequest: Codable {
    var userHash: String
    var selectedServices: [String: Bool]
    var isFaceIDEnabled: Bool
}

struct ServiceResponse: Codable {
    var selectedServices: [String: Bool]
    var isFaceIDEnabled: Bool
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isLoggedIn: Bool = true
        @State var hasSignedUp: Bool = true
        SettingsView(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp)
            .preferredColorScheme(.dark)
    }
}
