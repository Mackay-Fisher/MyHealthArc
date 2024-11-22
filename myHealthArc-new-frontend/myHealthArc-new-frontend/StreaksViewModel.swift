//
//  StreaksViewModel.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/21/24.
//
struct FitnessGoal: Identifiable {
    let id = UUID()
    let name: String
    let value: Int
    let color: Color
}

struct GoalColors {
    static let steps = Color.blue
    static let exercise = Color.purple
    static let calories = Color.pink
    static let sleep = Color.teal
    static let water = Color.blue
    static let workouts = Color.green
    static let nutrition = Color.orange
    static let elevation = Color.gray
    static let distance = Color.cyan
}

struct StreakFlameView: View {
    let streak: FitnessGoal

    private var flameSize: CGFloat {
        // Adjust size based on streak value
        let baseSize: CGFloat = 30
        let maxIncrease: CGFloat = 15
        let increase = min(CGFloat(streak.value) / 30.0, 1.0) * maxIncrease
        return baseSize + increase
    }

    private var formattedName: String {
        // Split by hyphen, capitalize each word, and join with a space
        streak.name
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }


    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Background glow
                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(streak.color.opacity(0.2))
                    .frame(width: flameSize + 10, height: flameSize + 10)

                // Main flame
                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()

                    .foregroundColor(streak.color)
                    .frame(width: flameSize, height: flameSize)
                Image(systemName: "flame")
                    .resizable()
                    .scaledToFit()

                    .foregroundColor(streak.color)
                    .frame(width: flameSize + 1, height: flameSize + 1)

                // Value
                Text("\(streak.value)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(height: 60)
            Text(formattedName) // Use the formatted name
                .font(.caption)
        }
    }
}


import SwiftUI

import Foundation
import SwiftUI

class StreaksViewModel: ObservableObject {
    @Published var streaks: [FitnessGoal] = []
    @Published var isLoading: Bool = true

    private let apiClient = APIClient()
    private let baseURL = "https://e0dc-198-217-29-75.ngrok-free.app/goals"
    private let userId = "dummy_user_id"

    func fetchStreaks() {
        isLoading = true
        guard let streaksURL = URL(string: "\(baseURL)/streaks?userId=\(userId)") else { return }

        URLSession.shared.dataTask(with: streaksURL) { [weak self] data, response, error in
            if let data = data, let fetchedStreaks = try? JSONDecoder().decode([String: Int].self, from: data) {
                DispatchQueue.main.async {
                    self?.streaks = fetchedStreaks.map { key, value in
                        FitnessGoal(
                            name: key.capitalized,
                            value: value,
                            color: self?.goalColor(for: key) ?? GoalColors.nutrition
                        )
                    }
                    self?.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                print("Error fetching streaks: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }

    private func goalColor(for goal: String) -> Color {
        switch goal {
        case "steps": return GoalColors.steps
        case "exercise": return GoalColors.exercise
        case "caloriesBurned": return GoalColors.calories
        case "sleep": return GoalColors.sleep
        case "water": return GoalColors.water
        case "workouts": return GoalColors.workouts
        case "elevation": return GoalColors.elevation
        case "distance": return GoalColors.distance
        default: return GoalColors.nutrition
        }
    }
}

import SwiftUI

struct StreaksView: View {
    @StateObject private var viewModel = StreaksViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // Header
                HStack {
                    Image("goals")
                        .resizable()
                        .scaledToFit()
                        .padding(-2)
                        .frame(width: 30)
                    Text("Streaks")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                }

                Divider()
                    .overlay(Color.gray.opacity(0.6))
                    .frame(height: 2)

                if viewModel.isLoading {
                    ProgressView("Loading Streaks...")
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 30) {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(viewModel.streaks) { streak in
                                    StreakFlameView(streak: streak)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                viewModel.fetchStreaks()
            }
        }
    }
}

// Preview provider
struct StreaksView_Previews: PreviewProvider {
    static var previews: some View {
        StreaksView()
            .preferredColorScheme(.light)
        
        StreaksView()
            .preferredColorScheme(.dark)
    }
}
