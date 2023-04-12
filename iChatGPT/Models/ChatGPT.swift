//
//  ChatGPT.swift
//  iChatGPT
//
//  Created by HTC on 2022/12/8.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import Foundation
import Combine
import OpenAI

class Chatbot {
    var timeout: TimeInterval = 60
	var userAvatarUrl = "https://raw.githubusercontent.com/37iOS/iChatGPT/main/icon.png"
    var openAIKey = ""
    var openAI: OpenAI
    var answer = ""
	
    init(openAIKey:String) {
        self.openAIKey = openAIKey
        self.openAI = OpenAI(apiToken: self.openAIKey)
	}

    func getUserAvatar() -> String {
        userAvatarUrl
    }

    func getChatGPTAnswer(prompts: [AIChat], sendContext: Bool, roomModel: ChatRoom?, completion: @escaping (String) -> Void) {
        // 构建对话记录
        print("prompts")
        print(prompts)
        var messages: [OpenAI.Chat] = []
        if sendContext {
            // 每次只放此次提问之前三轮问答，且答案只放前面100字，已经足够AI推理了
            let historyCount = roomModel?.historyCount ?? 3
            let prompts = Array(prompts.suffix(historyCount + 1))
            for i in 0..<prompts.count {
                if i == prompts.count - 1 {
                    messages.append(.init(role: .user, content: prompts[i].issue))
                    break
                }
                messages.append(.init(role: .user, content: prompts[i].issue))
                messages.append(.init(role: .assistant, content: String((prompts[i].answer ?? "").prefix(100))))
            }
        } else {
            messages.append(.init(role: .user, content: prompts.last?.issue ?? ""))
        }
        if let prompt = roomModel?.prompt, !prompt.isEmpty {
            messages.append(.init(role: .system, content: prompt))
        }
        
        print("message:")
        print(messages)
        let model = prompts.last?.model ?? "gpt-3.5-turbo"
        print("model:")
        print(model)
        openAI.chats(query: .init(model: model, messages: messages, temperature: roomModel?.temperature ?? 0.7), timeoutInterval: 30) { data in
            print("data:")
            print(data)
            do {
                let res = try data.get().choices[0].message.content
                DispatchQueue.main.async {
                    completion(res)
                }
            } catch {
                print(error)
                let errorMessage = error.localizedDescription
                DispatchQueue.main.async {
                    completion(errorMessage)
                }
            }
        }
    }

}
