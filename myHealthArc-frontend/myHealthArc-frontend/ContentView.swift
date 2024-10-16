 //
//  ContentView.swift
//  myHealthArc-frontend
//
//  Created by Anjali Hole on 10/9/24.
//

import SwiftUI

struct ContentView: View {
    @State var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            MainView()
        } else {
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
}

#Preview {
    ContentView()
}
