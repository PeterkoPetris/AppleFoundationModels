//
//  ChatbotApp.swift
//  AppleFoundationModels
//
//  Created by Učiteľ on 22/09/2025.
//

import SwiftUI

@main
struct ChatbotApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    NavigationLink("Chat Bot", destination: ChatBotView())
                    NavigationLink("Map", destination: MapGenerableView())
                }
                .navigationTitle("Main Menu")
            }
        }
    }
}
