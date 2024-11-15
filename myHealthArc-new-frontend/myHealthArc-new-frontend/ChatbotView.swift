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
   
    var body: some View {
        VStack {
            Button(action: {
            }) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                    Text("Recipe Assistant")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(10)
                .background(Color.blue)
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding(.leading, 20)
                .padding(.top, 20)
                Spacer()
            }
            VStack {
                MessagesListView(messages: viewModel.messages)
                
                var dietaryOptions = ["Vegetarian", "Vegan", "Gluten-Free"]
                var selectedDietaryOption = ""
                HStack {
                    ForEach(dietaryOptions, id: \.self) { option in
                        Button(action: {
                            viewModel.sendUserMessage(option)
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
                    }
                    .padding(.trailing)
                }
                .padding(.bottom)
            }
        }

    }
    
    func sendMessage() {
        guard !userMessage.isEmpty else { return }
        viewModel.sendUserMessage(userMessage)
        userMessage = "" 
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

        var body: some View {
            HStack {
                if message.isUser {
                    Spacer()
                    Text(message.message)
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                } else {
                    Text(message.message)
                        .padding(12)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
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
        ChatbotView(viewModel: ChatbotViewModel())
    }
}
