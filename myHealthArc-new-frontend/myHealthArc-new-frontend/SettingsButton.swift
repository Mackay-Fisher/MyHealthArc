//
//  SettingsButton.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/23/24.
//

import SwiftUI

struct SettingsButton: View {
    @Binding var showSettings: Bool // Control visibility of the settings view

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                showSettings.toggle() // Toggle the settings view
            }
        }) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(Color.mhaPurple)
                .padding()
        }
    }
}

