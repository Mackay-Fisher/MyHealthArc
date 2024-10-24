
//
//  MedicationsView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/23/24.

import SwiftUI

struct MedicationsView: View {
    @State private var medicationInput: String = ""
    @State private var addedMedications: [String] = []
    @State private var selectedMedications: Set<String> = [] // Track selected medications
    @State private var interactionResults: String = ""
    @State private var showInteraction: Bool = false
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            HStack{Image ("pills")
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
            // Input for new medication
            HStack {
                TextField("Enter medication name", text: $medicationInput)
                    .padding(.leading, 2)
                    .padding(5)
                    .background(colorScheme == .dark ? Color.mhaGray : Color.white)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(colorScheme == .dark ? Color.white : Color.gray, lineWidth: 1)
                    )
                    .frame(width: 250, height: 100, alignment:.center)
                
                Button("Add") {
                    addMedication()
                }
                .padding()
                .frame(width: 80, height: 40)
                .background(Color.mhaPurple)
                .cornerRadius(50)
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            }
            Text("Your Medications")
                .font(.title3)
                .padding()

            // List of added medications with checkboxes
            List {
                ForEach(addedMedications, id: \.self) { medication in
                    HStack {
                        // Checkbox for selecting medications
                        Button(action: {
                            toggleSelection(for: medication)
                        }) {
                            HStack {
                                Image(systemName: selectedMedications.contains(medication) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedMedications.contains(medication) ? .mhaGreen : .gray)
                                Text(medication)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                    }
                }
                .onDelete(perform: removeMedication)
            }
            .listStyle(PlainListStyle())

            if showInteraction {

                Text("Interaction Results:")
                    .font(.headline)
                    .padding()
                Divider()
                    .overlay(colorScheme == .dark ? Color.white : Color.black)
                    .frame(width: 200)
                Text(interactionResults)
                    .padding()
                
            }
            
            // Check interactions button
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
    }

    private func addMedication() {
        guard !medicationInput.isEmpty else { return }
        addedMedications.append(medicationInput)
        medicationInput = ""
    }

    private func removeMedication(at offsets: IndexSet) {
        // Remove medications from the selectedMedications set if they are being deleted
        for index in offsets {
            let medicationToRemove = addedMedications[index]
            selectedMedications.remove(medicationToRemove)
        }
        addedMedications.remove(atOffsets: offsets)
    }

    private func toggleSelection(for medication: String) {
        if selectedMedications.contains(medication) {
            selectedMedications.remove(medication) // Deselect if already selected
        } else {
            selectedMedications.insert(medication) // Select the medication
        }
    }

    private func checkInteractions() {
        // Placeholder for API call to check interactions
        if selectedMedications.count >= 2 {
            // Check interactions between selected medications
            interactionResults = "\(selectedMedications.joined(separator: ", ")) may interact with each other!"
        } else {
            interactionResults = "Select more medications to check for interactions."
        }
        showInteraction = true

    }
}

struct MedicationsView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationsView()
    }
}


