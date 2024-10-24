//
//  SettingsOverlayModifier.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/23/24.
//


import SwiftUI

struct SettingsOverlayModifier: ViewModifier {
    @Binding var showSettings: Bool
    @Binding var isLoggedIn: Bool
    @Binding var hasSignedUp: Bool
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        ZStack {
            content // Main view content
            
            if showSettings {
                Color.black.opacity(0.4) // Dimmed background
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            showSettings = false // Close settings when tapping outside
                        }
                    }

                SettingsView(isLoggedIn: $isLoggedIn, hasSignedUp: $hasSignedUp)
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.8) // 80% width
                    .background(colorScheme == .dark ? Color.mhaGray : Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .offset(x: showSettings ? 0 : UIScreen.main.bounds.width) // Slide-in
                    .animation(.easeInOut, value: showSettings)
                    .gesture(
                        DragGesture().onEnded { value in
                            if value.translation.width > 100 { // Swipe to close
                                withAnimation(.easeInOut) {
                                    showSettings = false
                                }
                            }
                        }
                    )
            }
        }
    }
}

// Convenience function to apply the settings overlay easily
extension View {
    func withSettingsOverlay(
        showSettings: Binding<Bool>,
        isLoggedIn: Binding<Bool>,
        hasSignedUp: Binding<Bool>
    ) -> some View {
        self.modifier(SettingsOverlayModifier(
            showSettings: showSettings,
            isLoggedIn: isLoggedIn,
            hasSignedUp: hasSignedUp
        ))
    }
}
