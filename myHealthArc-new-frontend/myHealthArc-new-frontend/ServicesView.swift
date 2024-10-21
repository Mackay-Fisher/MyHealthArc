//
//  ServicesView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/17/24.
//


//
//  servicesView.swift
//  myHealthArc-frontend
//
//  Created by Anjali Hole on 10/9/24.
//

import SwiftUI

struct ServicesView: View {
    @State private var selectedServices: Set<String> = []

    var services = ["Apple Health", "Apple Fitness", "Nutrition", "Prescriptions"]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {
            Text("Select Your Services")
                .font(.largeTitle)
                .padding(.bottom, 50)
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(services, id: \.self) { service in
                    ServiceButton(service: service, isChecked: selectedServices.contains(service)) {
                        toggleSelection(for: service)
                    }
                }
            }
            .padding(.bottom, 50)

            Button("Continue") {
                // handle selected services
                // Navigate to the next screen
            }
            .frame(width: 200, height: 50)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    private func toggleSelection(for service: String) {
        if selectedServices.contains(service) {
            selectedServices.remove(service)
        } else {
            selectedServices.insert(service)
        }
    }
}

struct ServiceButton: View {
    var service: String
    var isChecked: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                Circle()
                    .fill(isChecked ? Color.green : Color.clear)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: 2)
                    )
                    .padding(.bottom, 20)
                Text(service)
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .frame(width: 150, height: 150)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
    }
}

#Preview {
    ServicesView()
}