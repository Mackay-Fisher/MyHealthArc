//
//  ChatbotViewModel.swift
//  myHealthArc-new-frontend
//
//  Created by Phatak, Rhea on 11/12/24.
//

import SwiftUI
import OpenAI

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
            self.apiKey = ""
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
    }
}
