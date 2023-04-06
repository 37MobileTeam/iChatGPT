//
//  AIChatInputModel.swift
//  iChatGPT
//
//  Created by HTC on 2023/4/1.
//  Copyright © 2023 37 Mobile Games. All rights reserved.
//

import Foundation

enum InputViewAlert {
    case createNewChatRoom, reloadLastQuestion, clearAllQuestion, shareContents
}

class AIChatInputModel: ObservableObject {
    
    @Published var showingAlert = false
    @Published var activeAlert: InputViewAlert = .createNewChatRoom

    @Published var isShowAllChatRoom: Bool = false
    @Published var isConfigChatRoom: Bool = false
    @Published var isScrollToChatRoomTop: Bool = false
    @Published var searchText: String = ""
}
