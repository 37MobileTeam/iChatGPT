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
    @EnvironmentObject var model: AIChatInputModel
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading){
            inputToolBar()
            
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
                        Image(systemName: chatModel.isSendContext ? "text.bubble" : "bubble.left")
                            .scaleEffect(x: -1, y: 1)
                            .foregroundColor(chatModel.isSendContext ? .blue : .gray)
                            .padding(.leading, 8)
                            .padding(.trailing, 5)
                            .onTapGesture {
                                chatModel.isSendContext.toggle()
                            }
                        
                        TextView("Just ask..".localized(), text: $searchText, onEditingChanged: changedSearch(isEditing:), onCommit: fetchSearch)
                            .returnKeyType(.default)
                            .scrollIndicatorStyle(HiddenScrollViewIndicatorStyle())
                            .padding(.trailing, 3)
                            .padding([.top], 12)
                            .maxHeight(44)
                        
                        if searchText.count > 0 {
                            Button(action: clearSearch) {
                                Image(systemName: "multiply.circle.fill")
                            }
                            .padding(.trailing, 5)
                            .foregroundColor(.placeholderText)
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: fetchSearch) {
                                Image(systemName: "arrow.up.circle.fill")
                            }
                            .padding(.trailing, 8)
                            .foregroundColor(.green)
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
        .padding(.bottom, 10)
    }
    
    @ViewBuilder private func inputToolBar() -> some View {
        HStack {
            Spacer()
            
            Button(action: {
                model.activeAlert = .createNewChatRoom
                model.showingAlert.toggle()
            }) {
                Image(systemName: "plus.square.on.square")
            }
            .padding(.trailing, 5)
            .foregroundColor(.lightGray)
            .buttonStyle(PlainButtonStyle())
            
            if !chatModel.contents.isEmpty {
                Button(action: {
                    model.activeAlert = .reloadLastQuestion
                    model.showingAlert.toggle()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .padding(.trailing, 5)
                .foregroundColor(.lightGray)
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    model.activeAlert = .clearAllQuestion
                    model.showingAlert.toggle()
                }) {
                    Image(systemName: "trash")
                }
                .padding(.trailing, 5)
                .foregroundColor(.lightGray)
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    model.activeAlert = .shareContents
                    model.showingAlert.toggle()
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                .padding(.trailing, 5)
                .foregroundColor(.lightGray)
                .buttonStyle(PlainButtonStyle())
            }
            
            Button(action: {
                model.isShowAllChatRoom.toggle()
            }) {
                Image(systemName: "clock.arrow.circlepath")
            }
            .padding(.trailing, 5)
            .foregroundColor(.lightGray)
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                model.isConfigChatRoom.toggle()
            }) {
                Image(systemName: "gearshape")
            }
            .padding(.trailing, 8)
            .foregroundColor(.lightGray)
            .buttonStyle(PlainButtonStyle())
            
            if !chatModel.contents.isEmpty {
                Button(action: {
                    model.isScrollToChatRoomTop.toggle()
                }) {
                    if #available(iOS 15, *) {
                        Image(systemName: "arrow.up.to.line.compact")
                    } else {
                        Image(systemName: "arrow.up.to.line")
                    }
                }
                .padding(.trailing, 5)
                .foregroundColor(.lightGray)
                .buttonStyle(PlainButtonStyle())
            }
            
            if isEditing {
                Button(action: hideKeyboard) {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
                .padding(.trailing, 8)
                .foregroundColor(.lightGray)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.bottom, 5)
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
}
