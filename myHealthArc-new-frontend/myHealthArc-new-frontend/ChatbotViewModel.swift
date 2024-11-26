//
//  ChatbotViewModel.swift
//  myHealthArc-new-frontend
//
//  Created by Phatak, Rhea on 11/12/24.
//

import SwiftUI
import OpenAI
import SwiftKeychainWrapper

final class ChatbotViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    private var apiKey: String
    var proteinLeft: Double
    var carbsLeft: Double
    var fatsLeft: Double
    
    init(proteinLeft: Double, carbsLeft: Double, fatsLeft: Double) {
        self.proteinLeft = proteinLeft
        self.carbsLeft = carbsLeft
        self.fatsLeft = fatsLeft
        // retrieve the API key from the environment variable
        if let apiKeyFromEnv = ProcessInfo.processInfo.environment["OPENAI_KEY"] {
            self.apiKey = apiKeyFromEnv
        } else {
            self.apiKey = AppConfig.OPENAI_KEY
        }
    }
    
    func sendDefaultMessage() {
        let messagetoSend = "Suggest a recipe with approximately \(Int(proteinLeft))g protein, \(Int(carbsLeft))g carbs, and \(Int(fatsLeft))g fats."
        sendUserMessage(messagetoSend)
    }
    
    func sendUserMessage(_ message: String) {
        let userMessage = ChatMessage(message: message, isUser: true)
        messages.append(userMessage)
        
        let openAI = OpenAI(apiToken: self.apiKey)
        
        let query = ChatQuery(
            messages: [.init(role: .user, content: message)!],
            model: .gpt3_5Turbo
        )
        
        openAI.chats(query: query) { result in
            switch result {
            case .success(let success):
                guard let choice = success.choices.first else {
                    return
                }
                guard let message = choice.message.content?.string else { return }
                DispatchQueue.main.async {
                    self.receiveChatbotMessage(message)
                }
            case .failure(let failure):
                self.receiveChatbotMessage("Chatbot is not working. Please try again later.")
                print(failure)
            }
        }
    }
    
    private func receiveChatbotMessage(_ message: String) {
        let receivedMessage = ChatMessage(message: message, isUser: false)
        messages.append(receivedMessage)
        // Removed the automatic saveRecipe call
    }
    
    func saveRecipe(name: String, content: String) {
        guard let userHash = KeychainWrapper.standard.string(forKey: "userHash") else {
            print("DEBUG - Failed to retrieve userHash from Keychain")
            return
        }
        let recipe = Recipe(name: name, content: content, userHash: userHash, id: UUID())
        
        guard let url = URL(string: "\(AppConfig.baseURL)/recipes") else {
            print("DEBUG - Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(recipe)
            request.httpBody = jsonData
        } catch {
            print("DEBUG - Error encoding recipe: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("DEBUG - Error saving recipe: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("DEBUG - No data received")
                return
            }
            
            do {
                let savedRecipe = try JSONDecoder().decode(Recipe.self, from: data)
                print("DEBUG - Recipe saved successfully: \(savedRecipe)")
            } catch {
                print("DEBUG - Error decoding response: \(error)")
            }
        }.resume()
    }
}

struct Recipe: Codable, Identifiable {
    var name: String
    var content: String
    var userHash: String?
    let id: UUID
    
}
