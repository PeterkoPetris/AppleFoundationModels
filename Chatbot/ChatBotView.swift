//
//  ChatBotView.swift
//  AppleFoundationModels
//
//  Created by Učiteľ on 22/09/2025.
//

import SwiftUI
import FoundationModels

struct ChatBotView: View {
    @State private var userInput: String = ""
    @State private var answerString: String = ""
    @State private var isLoading: Bool = false
    @State private var session = LanguageModelSession()
    
    var body: some View {
        VStack(spacing: 20) {
            
            TextField("Type your question...", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                Task {
                    await generateAnswer(for: userInput)
                }
            }) {
                Text("Send")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isLoading ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(userInput.isEmpty || isLoading)
            .padding(.horizontal)
            
            ScrollView {
                Text(answerString)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .animation(.easeInOut(duration: 0.2), value: answerString)
            }
            
            Spacer()
        }
        .padding()
    }
    
    func generateAnswer(for prompt: String) async {
        do {
            isLoading = true
            answerString = ""
            
            let stream = session.streamResponse(to: prompt)
       
            for try await streamData in stream {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        answerString = streamData.content.asPartiallyGenerated()
                    }
                }
            }
        } catch {
            answerString = "❌ Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
