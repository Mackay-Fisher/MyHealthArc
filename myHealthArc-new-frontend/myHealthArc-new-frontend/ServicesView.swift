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
    var body: some View {
        VStack {
            Text("Select Your Services")
                .font(.largeTitle)
                .padding()
            
            // Add buttons for the services you want to show
            Button("Apple Health") {
                // Handle service selection
            }
            .padding()
            
            Button("Apple Fitness") {
                // Handle service selection
            }
            .padding()
            
            Button("Continue") {
                // Navigate to the next screen
            }
            .frame(width: 200, height: 50)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
#Preview {
    ServicesView()
}