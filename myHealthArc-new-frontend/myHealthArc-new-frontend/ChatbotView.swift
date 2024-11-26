//
//  ChatbotView.swift
//  myHealthArc-new-frontend
//
//  Created by Phatak, Rhea on 11/12/24.
//

import SwiftUI

struct ChatbotView: View {
    @ObservedObject var viewModel: ChatbotViewModel
    @State private var userMessage = ""
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(-2)
                    .frame(width: 15)
                Text("Recipe Assistant")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
            }.accentColor(.mhaGreen)
            
            Divider()

            VStack {
                MessagesListView(messages: viewModel.messages, viewModel: viewModel)
                
                let dietaryOptions = ["Vegetarian", "Vegan", "Gluten-Free"]
                HStack {
                    ForEach(dietaryOptions, id: \.self) { option in
                        Button(action: {
                            handleDietaryOption(option: option)
                        }) {
                            Text(option)
                                .foregroundColor(.mhaPurple)
                                .font(.body)
                                .padding(8)
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(2)
                        .cornerRadius(12)
                        .foregroundColor(.mhaPurple)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                    }
                }
                .padding()
            }
        }
        .onAppear() {
            viewModel.sendDefaultMessage()
        }
    }
    
    func sendMessage() {
        guard !userMessage.isEmpty else { return }
        viewModel.sendUserMessage(userMessage)
        userMessage = ""
    }
    
    func handleDietaryOption(option: String) {
        let dietary_send = "Make the recipe \(option.lowercased())"
        viewModel.sendUserMessage(dietary_send)
    }
}

struct MessagesListView: View {
    var messages: [ChatMessage]
    var viewModel: ChatbotViewModel
    
    var body: some View {
        List(messages) { message in
            MessageRow(message: message, viewModel: viewModel)
                .padding(.vertical, 5)
                .listRowSeparator(.hidden)
        }
        .listStyle(PlainListStyle())
        .cornerRadius(10)
    }
}

struct MessageRow: View {
    var message: ChatMessage
    var viewModel: ChatbotViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showingNameInput = false
    @State private var recipeName = ""
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
            HStack {
                if message.isUser {
                    Spacer()
                    Text(message.message)
                        .padding(12)
                        .background(Color.mhaPurple)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .multilineTextAlignment(.leading)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(message.message)
                            .padding(12)
                            .background(Color.mhaGreen.opacity(0.2))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                            .multilineTextAlignment(.leading)
                        
                        // Save Recipe Button
                        Button(action: {
                            showingNameInput = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "bookmark.fill")
                                Text("Save Recipe")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .foregroundColor(.mhaPurple)
                            .background(Color.mhaPurple.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.leading, 12)
                    }
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 10)
        .alert("Save Recipe", isPresented: $showingNameInput) {
            TextField("Recipe Name", text: $recipeName)
            Button("Cancel", role: .cancel) {
                recipeName = ""
            }
            Button("Save") {
                if !recipeName.isEmpty {
                    viewModel.saveRecipe(name: recipeName, content: message.message)
                    showingSaveConfirmation = true
                    recipeName = ""
                }
            }
        }
        .alert("Recipe Saved!", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your recipe has been saved successfully.")
        }
    }
}

struct ChatbotView_Previews: PreviewProvider {
    static var previews: some View {
        ChatbotView(viewModel: ChatbotViewModel(proteinLeft: 1, carbsLeft: 1, fatsLeft: 1))
    }
}

struct ChatMessage: Identifiable {
    var id = UUID()
    var message: String
    var isUser: Bool
}

