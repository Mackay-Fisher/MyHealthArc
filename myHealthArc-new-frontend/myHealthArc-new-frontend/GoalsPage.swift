//
//  GoalsPage.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 11/19/24.
//

import SwiftUI

struct FitnessGoal: Identifiable {
    let id = UUID()
    let name: String
    let value: Int
    let color: Color
}

class FitnessGoalsViewModel: ObservableObject {
    @Published var stepCount = 10000
    @Published var exerciseMinutes = 30
    @Published var caloriesBurned = 500
    @Published var timeAsleep = 8
    @Published var waterIntake = 8
    @Published var workoutsPerWeek = 6
    @Published var proteinGoal = 60
    @Published var carbsGoal = 300
    @Published var fatGoal = 50
    @Published var caloriesConsumed = 2200
    
    let streakCount = 14
}

struct GoalsView: View {
    
    
    var body: some View {
        
        
    }
}

#Preview {
    GoalsView()
}
