//
//  APIClient.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/20/24.
//
import Foundation

class APIClient {
    private let baseURL = "\(AppConfig.baseURL)"

    func fetchGoals(userHash: String, completion: @escaping (Result<[String: Int], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/goals/\(userHash)") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                if let goals = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Int] {
                    completion(.success(goals))
                } else {
                    completion(.failure(APIError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    func fetchStreaks(userHash: String, completion: @escaping (Result<[String: Int], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/streaks/\(userHash)") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                if let streaks = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Int] {
                    completion(.success(streaks))
                } else {
                    completion(.failure(APIError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

enum APIError: Error {
    case invalidURL
    case noData
    case invalidResponse
}
