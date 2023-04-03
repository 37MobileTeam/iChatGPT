//
//  AIChatRoom.swift
//  iChatGPT
//
//  Created by HTC on 2023/4/1.
//  Copyright © 2023 37 Mobile Games. All rights reserved.
//

import Foundation

struct ChatRoom: Codable {
    var roomID: String
    var roomName: String?
    var model: String?
    var prompt: String?
    var temperature: Double?
    var historyCount: Int = 3
}
