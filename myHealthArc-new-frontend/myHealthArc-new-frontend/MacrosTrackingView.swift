//
//  MacrosTrackingView.swift
//  myHealthArc-new-frontend
//
//  Created by Phatak, Rhea on 11/18/24.
//

import SwiftUI

struct MacrosTrackingView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var protein_left: Double = 22
    @State private var carbs_left: Double = 7
    @State private var fats_left: Double = 12
    @State private var protein_progress_left: Double = 0.4
    @State private var carbs_progress_left: Double = 0.7
    @State private var fats_progress_left: Double = 0.3
    @State private var showSheet = false
    
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
                
                // Progress Section
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        MacroProgressView(macroName: "Protein", value: protein_left, unit: "g", color: .blue, progress: protein_progress_left)
                        MacroProgressView(macroName: "Carbs", value: carbs_left, unit: "g", color: .orange, progress: carbs_progress_left)
                    }
                    
                    HStack(spacing: 20) {
                        MacroProgressView(macroName: "Fats", value: fats_left, unit: "g", color: .red, progress: fats_progress_left)
                        MacroProgressView(macroName: "Carbs", value: carbs_left, unit: "kcal", color: .green, progress: carbs_progress_left)
                    }
                }
                .padding()
                
                Spacer()
                    .frame(height:30)
                
                Button(action: {showSheet = true}) {
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
                    .sheet(isPresented: $showSheet) {
                        ChatbotView(viewModel: ChatbotViewModel(proteinLeft: protein_left, carbsLeft: carbs_left, fatsLeft: fats_left))
                    }
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
                .padding(.bottom)
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 17)
                Circle()
                    .trim(from: 0, to: progress) // Adjust for progress
                    .stroke(color, lineWidth: 17)
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
            .padding(.bottom)
        }
        .padding()
        .frame(width: 175, height: 175)
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
