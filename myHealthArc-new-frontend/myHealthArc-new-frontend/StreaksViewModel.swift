//
//  StreaksViewModel.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/21/24.
//

import Foundation
import SwiftUI
import SwiftKeychainWrapper

struct FitnessGoal: Identifiable {
    let id = UUID()
    let name: String
    let value: Int
    let color: Color
}

struct GoalColors {
    static let steps = Color.mhaBlue
    static let exercise = Color.mhaPurple
    static let calories = Color.pink
    static let sleep = Color.teal
    static let water = Color.mhaBlue
    static let workouts = Color.mhaGreen
    static let nutrition = Color.mhaOrange
    static let elevation = Color.gray
    static let distance = Color.cyan
}

struct StreakFlameView: View {
    let streak: FitnessGoal
    @Environment(\.colorScheme) var colorScheme

    private var flameSize: CGFloat {
        // Adjust size based on streak value
        let baseSize: CGFloat = 40
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




class StreaksViewModel: ObservableObject {
    @Published var streaks: [FitnessGoal] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    
    private let apiClient = APIClient()
    private let baseURL = "\(AppConfig.baseURL)/goals"
    private let userId = KeychainWrapper.standard.string(forKey: "userHash")

    func fetchStreaks() {
        isLoading = true
        errorMessage = nil
        
        // Define example streaks
        let exampleStreaks = [
            FitnessGoal(name: "Sleep", value: 35, color: .mhaOrange),
        ]
        
        guard let userId = KeychainWrapper.standard.string(forKey: "userHash") else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "User ID not found"
                self.streaks = exampleStreaks  // Show example streaks even if user ID not found
            }
            return
        }
        
        guard let streaksURL = URL(string: "\(baseURL)/streaks?userId=\(userId)") else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Invalid URL"
                self.streaks = exampleStreaks  // Show example streaks even if URL invalid
            }
            return
        }
        
        print("Fetching streaks from URL: \(streaksURL.absoluteString)")
        
        URLSession.shared.dataTask(with: streaksURL) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.streaks = exampleStreaks  // Show example streaks on network error
                    print("Network error: \(error)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Invalid response"
                    self.streaks = exampleStreaks  // Show example streaks on invalid response
                    return
                }
                
                print("Response status code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    self.errorMessage = "Server error: \(httpResponse.statusCode)"
                    self.streaks = exampleStreaks  // Show example streaks on server error
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    self.streaks = exampleStreaks  // Show example streaks when no data
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw response: \(responseString)")
                }
                
                do {
                    let fetchedStreaks = try JSONDecoder().decode([String: Int].self, from: data)
                    print("Decoded streaks: \(fetchedStreaks)")
                    
                    let realStreaks = fetchedStreaks.map { key, value in
                        FitnessGoal(
                            name: key,
                            value: value,
                            color: self.goalColor(for: key)
                        )
                    }
                    
                    // Combine real streaks with example streaks
                    self.streaks = realStreaks + exampleStreaks
                    
                } catch {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                    self.streaks = exampleStreaks  // Show example streaks on decode error
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }

    private func goalColor(for goal: String) -> Color {
        switch goal.lowercased() {
        case "steps": return GoalColors.steps
        case "exercise": return GoalColors.exercise
        case "caloriesburned": return GoalColors.calories
        case "sleep": return GoalColors.sleep
        case "water intake": return GoalColors.water
        case "workouts": return GoalColors.workouts
        case "elevation": return GoalColors.elevation
        case "distance": return GoalColors.distance
        default: return GoalColors.nutrition
        }
    }
}


struct StreaksView: View {
    @StateObject private var viewModel = StreaksViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // Header
                HStack {
                    Image(systemName: "flame.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(-2)
                        .frame(width: 30)
                        .foregroundColor(.mhaOrange)
                    Text("Streaks")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                }

                Divider()

                if viewModel.isLoading {
                    ProgressView("Loading Streaks...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text("Error loading streaks")
                            .font(.headline)
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Button("Retry") {
                            viewModel.fetchStreaks()
                        }
                        .padding()
                    }
                } else if viewModel.streaks.isEmpty {
                    VStack {
                        Text("No streaks found")
                            .font(.headline)
                        Text("Start achieving your goals to build streaks!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
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
