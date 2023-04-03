//
//  ChatMessageStore.swift
//  iChatGPT
//
//  Created by HTC on 2023/4/1.
//  Copyright © 2023 37 Mobile Games. All rights reserved.
//

import Foundation

// MARK: - MessageStore
class ChatMessageStore: ObservableObject {
    
    public static let shared = ChatMessageStore()
    
    private let fileManager = MessageFileManager()
    
    func lastMessage(_ roomID: String) -> AIChat? {
        return messages(forRoom: roomID).last
    }
    
    func messages(forRoom roomID: String) -> [AIChat] {
        let messages = fileManager.loadMessages(forRoom: roomID)
        return messages
    }
    
    func addMessage(roomID: String, chat: AIChat) {
        var messages = fileManager.loadMessages(forRoom: roomID)
        messages.append(chat)
        fileManager.saveMessages(messages, forRoom: roomID)
    }
    
    func updateMessages(roomID: String, chats: [AIChat]) {
        fileManager.saveMessages(chats, forRoom: roomID)
    }
    
    func deleteMessages(withDate datetime: String, roomID: String) {
        fileManager.deleteMessages(withDate: datetime, forRoom: roomID)
    }
}

// MARK: - MessageFileManager
class MessageFileManager {
    func saveMessages(_ messages: [AIChat], forRoom roomID: String) {
        do {
            let url = try getDocumentsDirectory().appendingPathComponent("\(roomID).json")
            let data = try JSONEncoder().encode(messages)
            try data.write(to: url, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Error saving messages: \(error.localizedDescription)")
        }
    }
    
    func deleteMessages(withDate datetime: String, forRoom roomID: String) {
        var conversationMessages = loadMessages(forRoom: roomID)
        conversationMessages.removeAll { $0.datetime == datetime }
        saveMessages(conversationMessages, forRoom: roomID)
    }
    
    func loadMessages(forRoom roomID: String) -> [AIChat] {
        do {
            let url = try getDocumentsDirectory().appendingPathComponent("\(roomID).json")
            let data = try Data(contentsOf: url)
            let messages = try JSONDecoder().decode([AIChat].self, from: data)
            return messages
        } catch {
            print("Error loading messages: \(error.localizedDescription)")
            return []
        }
    }
    
    private func getDocumentsDirectory() throws -> URL {
        return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
}

