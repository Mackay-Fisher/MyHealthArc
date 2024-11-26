//
//  GoalsManager.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/25/24.
//


import Foundation

class GoalsManager: ObservableObject {
    @Published var goals: [String: Int] = [:]
    @Published var isLoading: Bool = false
    
        // MARK: - Fetch Goals
    func fetchGoals(from url: String, userHash: String) async throws {
        guard let requestURL = URL(string: "\(url)/fetch?userId=\(userHash)") else {
            throw URLError(.badURL)
        }
        print(requestURL)

        DispatchQueue.main.async {
            self.isLoading = true
        }

        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: requestURL)
            if let fetchedGoals = try JSONSerialization.jsonObject(with: data) as? [String: Int] {
                DispatchQueue.main.async {
                    self.goals = fetchedGoals
                    print("Fetched Goals: \(fetchedGoals)")
                }
            }
        } catch {
            print("Error fetching goals: \(error)")
            throw error
        }
    }


        // MARK: - Save Goals
        func saveGoals(to url: String, userHash: String) async throws {
            guard let requestURL = URL(string: "\(url)/update") else {
                throw URLError(.badURL)
            }

            var request = URLRequest(url: requestURL)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let requestBody = ["userId": userHash, "goals": goals] as [String: Any]
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("Goals successfully saved!")
                } else {
                    print("Failed to save goals: \(response)")
                }
            } catch {
                print("Error saving goals: \(error)")
                throw error
            }
        }
    }
