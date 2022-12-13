//
//  AIChatModel.swift
//  iChatGPT
//
//  Created by HTC on 2022/12/8.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import Foundation

let ChatGPTUserAgentKey = "ChatGPTUserAgentKey"
let ChatGPTCfClearanceKey = "ChatGPTCfClearanceKey"
let ChatGPTSessionTokenKey = "ChatGPTSessionTokenKey"

// MARK: - Welcome1
struct AIChat: Codable {
    let datetime: String
    var issue: String
    var answer: String?
    var isResponse: Bool = false
    var userAvatarUrl: String
    var botAvatarUrl: String = "https://chat.openai.com/apple-touch-icon.png"
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
            let userAvatarUrl = self.bot?.getUserAvatar() ?? ""
            var chat = AIChat(datetime: Date().currentDateString(), issue: prompt, userAvatarUrl: userAvatarUrl)
            contents.append(chat)
            let content = await self.bot?.getChatResponse(prompt: prompt)
            DispatchQueue.main.async { [self] in
                chat.answer = content
                chat.isResponse = true
                contents[index] = chat
            }

        }
    }
    
    func reloadChatbot() {
        isRefreshSession = false
        let userAgent = UserDefaults.standard.string(forKey: ChatGPTUserAgentKey) ?? ""
        let cfClearance = UserDefaults.standard.string(forKey: ChatGPTCfClearanceKey) ?? ""
        let chatGPTSessionToken = UserDefaults.standard.string(forKey: ChatGPTSessionTokenKey) ?? ""
        bot = Chatbot(sessionToken: chatGPTSessionToken, cfClearance: cfClearance, userAgent: userAgent)
    }
}
