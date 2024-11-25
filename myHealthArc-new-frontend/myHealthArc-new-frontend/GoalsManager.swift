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
    func fetchGoals(from url: String, userHash: String) {
        guard let requestURL = URL(string: "\(url)/fetch?userId=\(userHash)") else {
            print("Invalid URL")
            return
        }

        isLoading = true
        URLSession.shared.dataTask(with: requestURL) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            guard let data = data, error == nil else {
                print("Error fetching goals: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                if let fetchedGoals = try JSONSerialization.jsonObject(with: data) as? [String: Int] {
                    DispatchQueue.main.async {
                        self?.goals = fetchedGoals
                    }
                }
            } catch {
                print("Error parsing goals JSON: \(error)")
            }
        }.resume()
    }

    // MARK: - Save Goals
    func saveGoals(to url: String, userHash: String) {
        guard let requestURL = URL(string: "\(url)/update") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = ["userId": userHash, "goals": goals] as [String: Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error saving goals: \(error)")
                return
            }
            print("Goals successfully saved!")
        }.resume()
    }
}
