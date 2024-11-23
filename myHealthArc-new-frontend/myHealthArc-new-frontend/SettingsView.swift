import SwiftUI
import LocalAuthentication
import SwiftKeychainWrapper

struct SettingsView: View {
    @State private var availableServices: [String] = ["Apple Health", "Apple Fitness", "Prescriptions", "Nutrition"]
    @State private var selectedServices: [String: Bool] = [:]
    @AppStorage("isFaceIDEnabled") private var isFaceIDEnabled: Bool = false
    @Binding var isLoggedIn: Bool
    @Binding var hasSignedUp: Bool
    @Environment(\.colorScheme) var colorScheme

    private let userId = "exampleUserId" // Replace this with dynamic userId later
    private let baseURL = "https://7e81-198-217-29-75.ngrok-free.app"

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

                Section {
                    Toggle("Enable FaceID", isOn: Binding(
                        get: { isFaceIDEnabled },
                        set: { value in
                            isFaceIDEnabled = value
                            updateFaceID(value)
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

                Spacer().frame(height: 20)

                Button("Logout") {
                    hasSignedUp = false
                    isLoggedIn = false
                }
                .fontWeight(.bold)
                .foregroundColor(.red)
                .frame(width: 200, height: 50)
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black : Color.lightbackground)
        .onAppear(perform: fetchServices)
        .onDisappear(perform: updateAllServices)
    }

    private func fetchServices() {
        guard let url = URL(string: "\(baseURL)/user-services/fetch?userId=\(userId)") else {
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
                    self.isFaceIDEnabled = response.isFaceIDEnabled
                }
            } catch {
                print("Failed to decode services: \(error.localizedDescription)")
            }
        }.resume()
    }

    private func updateAllServices() {
        guard let url = URL(string: "\(baseURL)/user-services/update") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ServiceRequest(
            userId: userId,
            selectedServices: selectedServices,
            isFaceIDEnabled: isFaceIDEnabled
        )

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            print("Failed to encode update data: \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to update services: \(error.localizedDescription)")
                return
            }

            print("All services updated successfully")
        }.resume()
    }

    private func updateFaceID(_ value: Bool) {
        isFaceIDEnabled = value
        updateAllServices()
    }
}

// MARK: - Request and Response Models
struct ServiceRequest: Codable {
    var userId: String
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
