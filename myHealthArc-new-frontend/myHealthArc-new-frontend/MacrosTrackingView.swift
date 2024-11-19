//
//  MacrosTrackingView.swift
//  myHealthArc-new-frontend
//
//  Created by Phatak, Rhea on 11/18/24.
//

import SwiftUI

struct MacrosTrackingView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                    HStack{Image ("pills") //change to macros image
                            .resizable()
                            .scaledToFit()
                            .padding(-2)
                            .frame(width: 30)
                        Text("Macros Tracking")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                    }
                    
                    Divider()
                        .overlay(
                            (colorScheme == .dark ? Color.white : Color.gray)
                        )
                    
                
                // Manage Goals Button
                NavigationLink(destination: NutritionView()/*change to ManageGoalsView when it is created*/) {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.green)
                        Text("Manage Goals")
                            .foregroundColor(.green)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                Spacer()
                    .frame(height:40)
                
                // Progress Section - change values to variables
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        MacroProgressView(macroName: "Protein", value: 55.0, unit: "g", color: .blue, progress: 0.8)
                        MacroProgressView(macroName: "Carbs", value: 5.0, unit: "g", color: .orange, progress: 0.7)
                    }
                    
                    HStack(spacing: 20) {
                        MacroProgressView(macroName: "Fats", value: 8.0, unit: "g", color: .red, progress: 0.2)
                        MacroProgressView(macroName: "Carbs", value: 177.0, unit: "kcal", color: .green, progress: 0.5)
                    }
                }
                .padding()
                
                Spacer()
                    .frame(height:40)
                
                NavigationLink(destination: ChatbotView(viewModel: ChatbotViewModel())) {
                    Spacer()
                    HStack {
                        
                        Image(systemName: "lightbulb.fill")
                            .frame(width: 28, height: 28)
                            .foregroundColor(.white)
                        Text("Recipe Assistant")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(10)
                    .background(Color.mhaPurple)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding(.leading, 20)
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                    
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
        }
    }
}

struct MacroProgressView: View {
    var macroName: String
    var value: Double
    var unit: String
    var color: Color
    var progress: Double
    
    var body: some View {
        VStack {
            Text(macroName)
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, lineWidth: 10)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text(String(format: "%.1f", value))
                        .font(.headline)
                        .bold()
                    Text(unit)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 80, height: 80)
        }
        .padding()
        .frame(width: 150, height: 150)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// Preview
struct MacrosTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        MacrosTrackingView()
    }
}
