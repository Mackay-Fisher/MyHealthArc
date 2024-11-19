//
//  GoalsView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 11/19/24.
//

import SwiftUI

struct GoalsView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            // Header with image and title
            HStack {
                Image("goals")
                    .resizable()
                    .scaledToFit()
                    .padding(-2)
                    .frame(width: 30)
                
                Text("Goals")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
            }

            Divider()
                .overlay(
                    colorScheme == .dark ? Color.white : Color.gray
                )

            Spacer()
                .frame(height: 20)

            Text("Set and track your personalized health and fitness goals.")
                .font(.title3)
                .padding()

            Spacer()
        }
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}

struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView()
    }
}
