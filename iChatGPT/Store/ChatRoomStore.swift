//
//  ChatRoomStore.swift
//  iChatGPT
//
//  Created by HTC on 2023/4/1.
//  Copyright © 2023 37 Mobile Games. All rights reserved.
//

import Foundation


class ChatRoomStore: ObservableObject {
    
    public static let shared = ChatRoomStore()
    
    func lastRoomId() -> String? {
        let chatRooms = chatRooms()
        return chatRooms.last?.roomID
    }
    
    func chatRoom(_ roomID: String) -> ChatRoom? {
        let chatRooms = chatRooms()
        return chatRooms.first(where: { $0.roomID == roomID })
    }

    func addChatRoom(_ room: ChatRoom) {
        var chatRooms = chatRooms()
        if let index = chatRooms.firstIndex(where: { $0.roomID == room.roomID }) {
            chatRooms[index] = room
        } else {
            chatRooms.append(room)
        }
        saveChatRooms(chatRooms)
    }

    func updateChatRoom(for roomID: String, room: ChatRoom) {
        var chatRooms = chatRooms()
        if let index = chatRooms.firstIndex(where: { $0.roomID == roomID }) {
            chatRooms[index] = room
            saveChatRooms(chatRooms)
        }
    }
    
    func removeChatRoom(roomID: String) {
        var chatRooms = chatRooms()
        if let index = chatRooms.firstIndex(where: { $0.roomID == roomID }) {
            chatRooms.remove(at: index)
            saveChatRooms(chatRooms)
        }
    }

    func chatRooms() -> [ChatRoom] {
        let userDefaults = UserDefaults.standard
        if let data = userDefaults.data(forKey: "AIChatRoomStore") {
            if let decodedData = try? JSONDecoder().decode([ChatRoom].self, from: data) {
                return decodedData
            }
        }
        return []
    }

    func saveChatRooms(_ chatRooms: [ChatRoom]) {
        let userDefaults = UserDefaults.standard
        if let encodedData = try? JSONEncoder().encode(chatRooms) {
            userDefaults.set(encodedData, forKey: "AIChatRoomStore")
        }
    }
}
