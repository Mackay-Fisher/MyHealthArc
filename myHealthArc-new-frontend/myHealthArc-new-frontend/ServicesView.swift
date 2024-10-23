//
//  ServicesView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/17/24.
//
import SwiftUI

struct ServicesView: View {
    @State private var selectedServices: Set<String> = []
    @Environment(\.colorScheme) var colorScheme
    @State private var userName: String = "User Name" // Placeholder for user name
    @State private var userEmail: String = "user@example.com" // Placeholder for user email
    @State private var showProfile: Bool = false // To toggle
    
    var services = ["Apple Health", "Apple Fitness", "Nutrition", "Prescriptions"]

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
                    // Profile icon
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
                        ServiceButton(service: service, isChecked: selectedServices.contains(service)) {
                            toggleSelection(for: service)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    // Continue button action
                }) {
                    Text("Continue")
                        .frame(width: 200, height: 50)
                        .background(Color.mhaPurple)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .padding(.bottom, 30)
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
            .navigationBarHidden(true)
            .overlay(
                Group {
                    if showProfile {
                        UserProfileView(userName: userName, userEmail: userEmail, showProfile: $showProfile)
                    }
                }
            )
        }
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
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                HStack {
                    Circle()
                        .stroke(Color.gray, lineWidth: 2)
                        .background(Circle().fill(isChecked ? Color.mhaGreen : Color.clear))
                        .frame(width: 20, height: 20)
                        .padding(.top, 25 )
                        .padding(.leading, 15)
                    Spacer()
                }
                

                
                Image(systemName: service) // Placeholder for custom icons
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding(.bottom, 10)
                
                Text(service)
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Spacer()
                Spacer()
            }
            .frame(width: 160, height: 160)
            .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
            .cornerRadius(30)
            .shadow(radius: 3)
        }
    }
}

struct ServicesView_Previews: PreviewProvider {
    static var previews: some View {
        ServicesView()
    }
}
