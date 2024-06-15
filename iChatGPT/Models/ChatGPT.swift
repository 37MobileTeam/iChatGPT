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

let kDeafultAPIHost = "api.openai.com"
let kDeafultAPITimeout = 60.0
let kAPIModels = [Model.gpt4_o, Model.gpt4_turbo, Model.gpt3_5Turbo, Model.gpt4, Model.gpt4_32k, Model.gpt4_32k_0613, Model.gpt3_5Turbo_16k, Model.gpt3_5Turbo_16k_0613]

class Chatbot {
    var timeout: TimeInterval = 60
	var userAvatarUrl = "" //"https://raw.githubusercontent.com/37iOS/iChatGPT/main/icon.png"
    var openAIKey = ""
    var openAI: OpenAI
    var answer = ""
	
    init(openAIKey:String, timeout: TimeInterval = kDeafultAPITimeout, host: String? = kDeafultAPIHost) {
        self.openAIKey = openAIKey
        let config = OpenAI.Configuration(token: self.openAIKey, host: host ?? kDeafultAPIHost, timeoutInterval: timeout)
        self.openAI = OpenAI(configuration: config)
	}

    func getUserAvatar() -> String {
        userAvatarUrl
    }

    func getChatGPTAnswer(prompts: [AIChat], sendContext: Bool, isStream: Bool, roomModel: ChatRoom?, completion: @escaping (String) -> Void) {
        // 构建对话记录
        print("prompts")
        print(prompts)
        var messages: [ChatQuery.ChatCompletionMessageParam] = []
        if sendContext {
            // 每次只放此次提问之前三轮问答，且答案只放前面100字，已经足够AI推理了
            let historyCount = roomModel?.historyCount ?? 3
            let prompts = Array(prompts.suffix(historyCount + 1))
            for i in 0..<prompts.count {
                if i == prompts.count - 1 {
                    if let param: ChatQuery.ChatCompletionMessageParam = .init(role: .user, content: prompts[i].issue) {
                        messages.append(param)
                    }
                    break
                }
                if let param: ChatQuery.ChatCompletionMessageParam = .init(role: .user, content: prompts[i].issue) {
                    messages.append(param)
                }
                if let param: ChatQuery.ChatCompletionMessageParam = .init(role: .assistant, content: String((prompts[i].answer ?? "").prefix(100))) {
                    messages.append(param)
                }
            }
        } else {
            if let param: ChatQuery.ChatCompletionMessageParam = .init(role: .user, content: prompts.last?.issue ?? "") {
                messages.append(param)
            }
        }
        if let prompt = roomModel?.prompt, !prompt.isEmpty {
            if let param: ChatQuery.ChatCompletionMessageParam = .init(role: .system, content: prompt) {
                messages.append(param)
            }
        }
        
        print("message:")
        print(messages)
        let model = prompts.last?.model ?? "gpt-3.5-turbo"
        print("model:")
        print(model)
        let query = ChatQuery.init(messages: messages, model: model, temperature: roomModel?.temperature ?? 0.7)
        // Chats Streaming
        if isStream {
            openAI.chatsStream(query: query) { partialResult in
                switch partialResult {
                case .success(let chatResult):
                    //print(chatResult.choices)
                    if let res = chatResult.choices.first?.delta.content {
                        DispatchQueue.main.async {
                            completion(res)
                        }
                    }
                case .failure(let error):
                    //Handle chunk error here
                    print(error)
                    let errorMessage = error.localizedDescription
                    DispatchQueue.main.async {
                        completion(errorMessage)
                    }
                }
            } completion: { error in
                //Handle streaming error here
                print(error ?? "Unknown Error.")
                if let errorMessage = error?.localizedDescription {
                    DispatchQueue.main.async {
                        completion(errorMessage)
                    }
                }
            }
        } else {
            openAI.chats(query: query) { result in
                print("data:")
                print(result)
                switch result {
                case .success(let chatResult):
                    let res = chatResult.choices.first?.message.content
                    DispatchQueue.main.async {
                        completion(res?.string ?? "Unknown Error.")
                    }
                case .failure(let error):
                    print(error)
                    let errorMessage = error.localizedDescription
                    DispatchQueue.main.async {
                        completion(errorMessage)
                    }
                }
            }
        }
    }

}
