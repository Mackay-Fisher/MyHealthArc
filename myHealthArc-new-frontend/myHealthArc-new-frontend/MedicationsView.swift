//
//  MedicationsView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/23/24.
//


import SwiftUI

struct MedicationsView: View {
    @State private var medicationInput: String = ""
    @State private var addedMedications: [String] = []
    @State private var selectedMedication: String = ""
    @State private var interactionResults: String = ""
    @State private var showInteraction: Bool = false
//TODO: add profile stuff
    var body: some View {
        VStack {
            Text("Interaction Checker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            // Input for new medication
            HStack {
                TextField("Enter medication name", text: $medicationInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Add") {
                    addMedication()
                }
                .padding()
            }

            // List of added medications
            List {
                ForEach(addedMedications, id: \.self) { medication in
                    Text(medication)
                }
                .onDelete(perform: removeMedication)
            }

            // Dropdown for selecting a medication
            Picker("Select Medication", selection: $selectedMedication) {
                ForEach(addedMedications, id: \.self) { medication in
                    Text(medication)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            // Check interactions
            Button("Check Interactions") {
                checkInteractions()
            }
            .padding()

            // Show results
            if showInteraction {
                Text("Interaction Results:")
                    .font(.headline)
                    .padding()
                Text(interactionResults)
                    .padding()
            }

            Spacer()
        }
        .padding()
    }

    private func addMedication() {
        guard !medicationInput.isEmpty else { return }
        addedMedications.append(medicationInput)
        medicationInput = ""
    }

    private func removeMedication(at offsets: IndexSet) {
        addedMedications.remove(atOffsets: offsets)
    }

    private func checkInteractions() {
        // Placeholder for API call to check interactions
        // Simulating an API call with dummy data
        if addedMedications.count >= 2 {
            interactionResults = "\(selectedMedication) may interact with other medications!"
        } else {
            interactionResults = "Add more medications to check for interactions."
        }
        showInteraction = true
    }
}

struct MedicationsView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationsView()
    }
}
