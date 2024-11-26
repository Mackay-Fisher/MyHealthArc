//
//  MedicationWidget.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/24/24.
//
import SwiftUI
import SwiftKeychainWrapper

// Response data structures
struct InteractionResponse: Codable {
    var interactionsBySeverity: [String: [InteractionDetail]]?
    var error: Bool?
    var reason: String?
}

struct InteractionDetail: Codable {
    var description: String
    var severity: String
    var interaction: String
}

struct MedicationWidget: View {
    @State private var firstMedication: String = ""
    @State private var secondMedication: String = ""
    @State private var interactionResults: [String: [InteractionDetail]] = [:]
    @State private var showInteraction: Bool = false
    @State private var errorMessage: String = ""

    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationLink(destination: MedicationsView()) {
            VStack {
                HStack {
                    Spacer()
                    HStack {
                        Image("pills")
                            .resizable()
                            .scaledToFit()
                            .padding(-1)
                            .frame(width: 30)
                        
                        Spacer()
                            .frame(width: 15)
                        
                        Text("Medication Comparison")
                            .font(.headline)
                            .padding(.top)
                            .frame(alignment: .leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .padding(.top)
                        .foregroundColor(colorScheme == .dark ? Color.lightbackground : Color.gray)
                }
                
                Divider()
                Spacer()
                    .frame(height:15)
                HStack {
                    TextField("Medication 1", text: $firstMedication)
                        .textInputAutocapitalization(.words)
                        .padding(5)
                        .background(colorScheme == .dark ? Color.mhaGray : Color.white)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(colorScheme == .dark ? Color.white : Color.gray, lineWidth: 0.5)
                        )
                    Text ("vs.")
                    TextField("Medication 2", text: $secondMedication)
                        .textInputAutocapitalization(.words)
                        .padding(5)
                        .background(colorScheme == .dark ? Color.mhaGray : Color.white)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(colorScheme == .dark ? Color.white : Color.gray, lineWidth: 0.5)
                        )
                }
                
                // Compare Button
                Button(action: checkInteractions) {
                    Text("Compare")
                        .padding()
                        .frame(width: 150)
                        .background(Color.mhaPurple)
                        .foregroundColor(.white)
                        .cornerRadius(50)
                }
                .padding()
                
                // Display interaction results
                if showInteraction {
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(errorMessage.contains("No known interactions") ? .primary : .red)
                            .padding()
                    } else if !interactionResults.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 15) {
                                ForEach(Array(interactionResults.keys.sorted()), id: \.self) { severity in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(severity)
                                            .font(.headline)
                                            .foregroundColor(severityColor(severity))
                                        
                                        ForEach(interactionResults[severity] ?? [], id: \.description) { interaction in
                                            Text(interaction.description)
                                                .font(.subheadline)
                                                .padding(.leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                    .padding(.bottom, 5)
                                }
                            }
                            .padding()
                        }
                        .frame(maxHeight: 200)
                    }
                    
                    Button(action: clearSearch) {
                        Text("Clear")
                            .padding()
                            .background(Color.mhaGreen)
                            .cornerRadius(50)
                            .foregroundColor(.white)
                    }
                    .padding(.top)
                }
            }
            .frame(maxWidth: 320)
            .padding()
            .background(colorScheme == .dark ? Color.mhaGray : Color.white)
            .cornerRadius(30)
            .shadow(radius: 0.2)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func severityColor(_ severity: String) -> Color {
        switch severity {
        case "Serious - Use Alternative":
            return .red
        case "Monitor Closely":
            return .orange
        case "Minor":
            return .green
        default:
            return .primary
        }
    }

    private func clearSearch() {
        firstMedication = ""
        secondMedication = ""
        interactionResults = [:]
        errorMessage = ""
        showInteraction = false
    }

    private func checkInteractions() {
        guard !firstMedication.isEmpty && !secondMedication.isEmpty else {
            errorMessage = "Please enter both medications to check for interactions."
            showInteraction = true
            return
        }

        // Get userHash from Keychain
        guard let userHash = KeychainWrapper.standard.string(forKey: "userHash") else {
            errorMessage = "Please log in to check interactions."
            showInteraction = true
            return
        }

        // Create array of medications and join them with comma
        let medications = [firstMedication, secondMedication]
        let medicationsQuery = medications.joined(separator: ",")

        // Prepare the URL with query parameters including user hash
        let baseURL = "\(AppConfig.baseURL)/medicationChecker/check"
        guard let encodedQuery = medicationsQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?medications=\(encodedQuery)&userHash=\(userHash)") else {
            errorMessage = "Error creating request."
            showInteraction = true
            return
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Perform the API call
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Network Error: \(error)")
                    errorMessage = "Failed to check interactions."
                    showInteraction = true
                    return
                }

                guard let data = data else {
                    errorMessage = "No data received."
                    showInteraction = true
                    return
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(InteractionResponse.self, from: data)
                    
                    // Handle response based on content
                    if let reason = decodedResponse.reason, reason.contains("Data corrupted") {
                        // This seems to be the response when no interactions are found
                        errorMessage = "No known interactions found between \(firstMedication) and \(secondMedication)."
                        interactionResults = [:]
                    } else if let interactions = decodedResponse.interactionsBySeverity {
                        // We have found interactions
                        interactionResults = interactions
                        errorMessage = ""
                    } else if let isError = decodedResponse.error, isError {
                        // Handle other errors
                        errorMessage = decodedResponse.reason ?? "Unknown error occurred"
                        interactionResults = [:]
                    }
                    
                    showInteraction = true
                    
                } catch {
                    print("Decoding error: \(error)")
                    errorMessage = "Error processing response."
                    showInteraction = true
                }
            }
        }.resume()
    }
}

struct MedicationWidget_Previews: PreviewProvider {
    static var previews: some View {
        MedicationWidget()
    }
}
