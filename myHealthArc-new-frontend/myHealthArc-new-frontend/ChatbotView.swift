//
//  SwiftUIView.swift
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
            HStack{Image(systemName: "lightbulb.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(-2)
                    .frame(width: 15)
                Text("Recipe Assistant")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
            }
            
            Divider()
                .overlay(
                    (colorScheme == .dark ? Color.white : Color.gray)
                )
            VStack {
                MessagesListView(messages: viewModel.messages)
                
                let dietaryOptions = ["Vegetarian", "Vegan", "Gluten-Free"]
                HStack {
                    ForEach(dietaryOptions, id: \.self) { option in
                        Button(action: {
                            handleDietaryOption(option: option)
                        }) {
                            Text(option)
                                .font(.body)
                                .padding(8)
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(2)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                    }
                }
                .padding()
                
                /*
                HStack {
                    TextField("Enter your message", text: $userMessage)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                        .padding()
                    
                    Button(action: sendMessage) {
                        Text("Send")
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                    .padding(10)
                    .background(Color.mhaPurple)
                    .cornerRadius(12)
                }
                .padding(.bottom)
                .padding(.trailing)
                 */
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
            
        var body: some View {
            List(messages) { message in
                MessageRow(message: message)
                    .padding(.vertical, 5)
                    .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .cornerRadius(10)
        }
    }

    struct MessageRow: View {
        var message: ChatMessage
        @Environment(\.colorScheme) var colorScheme
        var body: some View {
            HStack {
                if message.isUser {
                    Spacer()
                    Text(message.message)
                        .padding(12)
                        .background(Color.mhaPurple)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                } else {
                    Text(message.message)
                        .padding(12)
                        .background(Color.mhaGreen.opacity(0.2))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                    Spacer()
                }
            }
            .padding(.horizontal, 10)
        }
    }

struct ChatMessage: Identifiable {
    var id = UUID()
    var message: String
    var isUser: Bool
}

struct ChatbotView_Previews: PreviewProvider {
    static var previews: some View {
        ChatbotView(viewModel: ChatbotViewModel(proteinLeft: 1, carbsLeft: 1, fatsLeft: 1)) //dummy values for preview purposes
    }
}
