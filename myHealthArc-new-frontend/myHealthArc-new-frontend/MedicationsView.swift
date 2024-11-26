
//
//  MedicationsView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/23/24.

import SwiftUI
import Foundation
import SwiftKeychainWrapper  // Added this to match widget

struct FormattedInteractionResponse: Codable {
    var interactionsBySeverity: [String: [FormattedInteraction]]?
    var error: Bool?
    var reason: String?
}

struct FormattedInteraction: Codable {
    var severity: String
    var interaction: String
    var description: String
}

struct MedicationsView: View {
    @State private var medicationInput: String = ""
    @State private var addedMedications: [String] = []
    @State private var selectedMedications: Set<String> = []
    @State private var interactionResults: [String: [FormattedInteraction]] = [:]
    @State private var showInteraction: Bool = false
    @State private var showAddPopup: Bool = false
    @State private var errorMessage: String = ""
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            if showAddPopup {
                VStack (spacing: 20) {
                    Text("Add Medications")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Divider()
                        .overlay(
                            (colorScheme == .dark ? Color.white : Color.gray)
                        )
                        .padding(.horizontal)
                    
                    TextField("Enter medication name", text: $medicationInput)
                        .textInputAutocapitalization(.words)
                        .padding(10)
                        .frame(maxWidth: 300)
                        .background(colorScheme == .dark ? Color.mhaGray : Color.white)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(colorScheme == .dark ? Color.white : Color.gray, lineWidth: 0.5)
                        )
                    
                    Button(action: {
                        addMedication()
                    }) {
                        Text("Add")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.mhaPurple)
                            .cornerRadius(50)
                            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                            .font(.headline)
                    }
                    .frame(height: 45)
                    
                    Button(action: {
                        showAddPopup = false
                    }) {
                        Text("Cancel")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    .padding(.bottom, 20)
                }
                .padding()
                .frame(maxWidth: 400)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(colorScheme == .dark ? Color.black : Color.white)
                        .shadow(color: colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.5), radius: 10)
                )
                .padding(30)
                .zIndex(1)
            }
            
            VStack {
                HStack {
                    Image("pills")
                        .resizable()
                        .scaledToFit()
                        .padding(-2)
                        .frame(width: 30)
                    Text("Medications")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                }
                
                Divider()
                    .overlay(
                        (colorScheme == .dark ? Color.white : Color.gray)
                    )
                Spacer()
                    .frame(height:20)
                
                HStack {
                    Text("Your Medications")
                        .font(.title3)
                        .padding()
                    Spacer()
                    Button(action: {
                        showAddPopup = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.mhaPurple)
                    }
                }
                
                List {
                    ForEach(addedMedications, id: \.self) { medication in
                        HStack {
                            Button(action: {
                                toggleSelection(for: medication)
                            }) {
                                HStack {
                                    Image(systemName: selectedMedications.contains(medication) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedMedications.contains(medication) ? .mhaGreen : .gray)
                                    Text(medication)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Button(action: {
                                        if let index = addedMedications.firstIndex(of: medication) {
                                            removeMedication(at: IndexSet([index]))
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                    .onDelete(perform: removeMedication)
                }
                .listStyle(PlainListStyle())

                if showInteraction {
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(errorMessage.contains("No known interactions") ? .primary : .red)
                            .padding()
                    } else if !interactionResults.isEmpty {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Interaction Results:")
                                    .font(.headline)
                                    .padding()
                                Spacer()
                                Button(action: {
                                    showInteraction = false
                                    interactionResults = [:]
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 24))
                                }
                                .padding(.trailing)
                            }
                            
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
                            .frame(maxHeight: 300)
                        }
                    }
                }
                
                Button("Check Interactions") {
                    checkInteractions()
                }
                .padding()
                .frame(width: 200)
                .background(Color.mhaGreen)
                .cornerRadius(50)
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)

            }
            .padding()
            .background(colorScheme == .dark ? Color.black : Color.white)
            .blur(radius: showAddPopup ? 10 : 0)
        }
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

    private func addMedication() {
        guard !medicationInput.isEmpty else { return }
        addedMedications.append(medicationInput)
        medicationInput = ""
        showAddPopup = false
    }

    private func removeMedication(at offsets: IndexSet) {
        for index in offsets {
            let medicationToRemove = addedMedications[index]
            selectedMedications.remove(medicationToRemove)
        }
        addedMedications.remove(atOffsets: offsets)
    }

    private func toggleSelection(for medication: String) {
        if selectedMedications.contains(medication) {
            selectedMedications.remove(medication)
        } else {
            selectedMedications.insert(medication)
        }
    }

    private func checkInteractions() {
        guard selectedMedications.count >= 2 else {
            errorMessage = "Select more medications to check for interactions."
            interactionResults = [:]
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
        let medicationsQuery = selectedMedications.joined(separator: ",")

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
                    let decodedResponse = try JSONDecoder().decode(FormattedInteractionResponse.self, from: data)
                    
                    // Handle response based on content
                    if let reason = decodedResponse.reason, reason.contains("Data corrupted") {
                        // This seems to be the response when no interactions are found
                        errorMessage = "No known interactions found between the selected medications."
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

struct MedicationsView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationsView()
    }
}
