//
//  ChatInputView.swift
//  iChatGPT
//
//  Created by HTC on 2022/12/8.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import SwiftUI
import SwiftUIX

struct ChatInputView: View {
    
    @Binding var searchText: String
    @StateObject var chatModel: AIChatModel
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            ZStack(alignment: .leading){
                Rectangle()
                #if os(macOS)
                    .foregroundColor(Color(NSColor.gray))
                #else
                    .foregroundColor(Color(UIColor.tertiarySystemGroupedBackground))
                #endif
                    .cornerRadius(10)
                    .frame(height: 40)
                HStack {
                    
                    if #available(iOS 15.0, *) {
                        Image(systemName: "message.and.waveform")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                            .padding(.trailing, 5)
                    } else {
                        Image(systemName: "message")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                            .padding(.trailing, 5)
                    }
                    
                    textView()
                        .textFieldStyle(.plain)
                        .padding(.trailing, 8)
                    
                    if searchText.count > 0 {
                        Button(action: clearSearch) {
                            Image(systemName: "multiply.circle.fill")
                        }
                        .padding(.trailing, 8)
                        .foregroundColor(.gray)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            if isEditing {
                Button(action: cancelSearch) {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.bottom, 10)
    }
    
    @ViewBuilder private func textView() -> some View {
        if #available(iOS 15.0, *) {
            CocoaTextField("Just ask..".localized(), text: $searchText, onEditingChanged: changedSearch(isEditing:), onCommit: fetchSearch)
                .submitLabel(.send)
        } else {
            // Fallback on earlier versions
            CocoaTextField("Just ask..".localized(), text: $searchText, onEditingChanged: changedSearch(isEditing:), onCommit: fetchSearch)
        }
    }
    
    func changedSearch(isEditing: Bool) {
        self.isEditing = isEditing
    }
    
    func fetchSearch() {
        guard !searchText.isEmpty else {
            return
        }
        #if DEBUG
        debugPrint(searchText)
        #endif
        chatModel.getChatResponse(prompt: searchText)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            clearSearch()
        }
    }
    
    func clearSearch() {
        searchText = ""
    }
    
    func cancelSearch() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
