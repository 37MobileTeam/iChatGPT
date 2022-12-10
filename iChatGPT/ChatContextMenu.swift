//
//  ChatContextMenu.swift
//  iChatGPT
//
//  Created by HTC on 2022/12/8.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import SwiftUI

struct ChatContextMenu: View {
    
    @Binding var searchText: String
    @StateObject var chatModel: AIChatModel
    let item: AIChat
    
    var body: some View {
        VStack {
            CreateMenuItem(text: "重新提问", imgName: "arrow.up.message") {
                chatModel.getChatResponse(prompt: item.issue)
            }
            CreateMenuItem(text: "复制问题", imgName: "doc.on.doc") {
                item.issue.copyToClipboard()
            }
            
            CreateMenuItem(text: "复制答案", imgName: "doc.on.doc") {
                item.answer!.copyToClipboard()
            }
            .disabled(item.answer == nil)
            
            CreateMenuItem(text: "复制问题和答案", imgName: "doc.on.doc.fill") {
                "\(item.issue)\n-----------\n\(item.answer ?? "")".copyToClipboard()
            }
            .disabled(item.answer == nil)
            
            CreateMenuItem(text: "复制问题到输入框", imgName: "keyboard.badge.ellipsis") {
                searchText = item.issue
            }
            
            // remove item
            let isWait = chatModel.contents.filter({ $0.isResponse == false })
            CreateMenuItem(text: "删除问题", imgName: "trash", isDestructive: true) {
                if let index = chatModel.contents.firstIndex(where: { $0.datetime == item.datetime })
                {
                    chatModel.contents.remove(at: index)
                }
            }.disabled(isWait.count > 0)
        }
    }
    
    func CreateMenuItem(text: String, imgName: String, isDestructive: Bool = false, onAction: (() -> Void)?) -> some View {
        if #available(iOS 15.0, *) {
            return Button(role: isDestructive ? .destructive : nil) {
                onAction?()
            } label: {
                Label(text, systemImage: imgName)
            }
        } else {
            return Button {
                onAction?()
            } label: {
                Label(text, systemImage: imgName)
            }
        }
    }
}

//struct ChatContextMenu_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        ChatContextMenu(item: AIChat(datetime: Date().currentDateString(), issue: "我是问题~", answer: "答案是我"), searchText: $searchText)
//    }
//}
