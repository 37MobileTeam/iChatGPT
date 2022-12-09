//
//  AIChatModel.swift
//  iChatGPT
//
//  Created by HTC on 2022/12/8.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import Foundation

let ChatGPTSessionTokenKey = "ChatGPTSessionTokenKey"

// MARK: - Welcome1
struct AIChat: Codable {
    let datetime: String
    var issue: String
    var answer: String?
    var isResponse: Bool = false
}


@MainActor
class AIChatModel: ObservableObject {
    
    var isRefreshSession: Bool = false
    @Published var contents: [AIChat] = []
    private var bot: Chatbot?
    
    init(contents: [AIChat]) {
        self.contents = contents
        reloadChatbot()
    }
    
    func getChatResponse(prompt: String) {
        Task {
            if isRefreshSession {
                reloadChatbot()
            }
            let index = contents.count
            var chat = AIChat(datetime: Date().currentDateString(), issue: prompt)
            contents.append(chat)
            let content = await self.bot?.getChatResponse(prompt: prompt)
            chat.answer = content
            chat.isResponse = true
            contents[index] = chat
        }
    }
    
    func reloadChatbot() {
        isRefreshSession = false
        let chatGPTSessionToken = UserDefaults.standard.string(forKey: ChatGPTSessionTokenKey) ?? ""
        bot = Chatbot(sessionToken: chatGPTSessionToken)
    }
}
