//
//  MedicationWidget.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/24/24.
//


import SwiftUI

struct MedicationWidget: View {
    @State private var firstMedication: String = ""
    @State private var secondMedication: String = ""
    @State private var interactionResults: String = ""
    @State private var showInteraction: Bool = false

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
                    VStack(alignment: .leading) {
                        Text("Interaction Results:")
                            .font(.headline)
                        Text(interactionResults)
                            .padding(.top, 2)
                            .padding(.bottom)
                        Button(action: clearSearch) {
                            Text("Clear")
                                .padding()
                                .background(Color.mhaGreen)
                                .cornerRadius(50)
                                .foregroundColor(.white)
                        }
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding()
                }
            }
            .frame(maxWidth: 320)
            .padding()
            .background(colorScheme == .dark ? Color.mhaGray : Color.white)
            .cornerRadius(30)
            .shadow(radius: 0.2)
        }
        .buttonStyle(PlainButtonStyle())
        //.padding()
    }
    private func clearSearch() {
            firstMedication = ""
            secondMedication = ""
            interactionResults = ""
            showInteraction = false // Hide interaction results
        }
    private func checkInteractions() {
        // Placeholder for interaction checking logic
        if !firstMedication.isEmpty && !secondMedication.isEmpty {
            // Mock interaction check logic
            interactionResults = "\(firstMedication) and \(secondMedication) may interact with each other!"
        } else {
            interactionResults = "Please enter both medications to check for interactions."
        }
        showInteraction = true
    }
}

struct MedicationWidget_Previews: PreviewProvider {
    static var previews: some View {
        MedicationWidget()
    }
}
