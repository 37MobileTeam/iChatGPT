//
//  AIChatView.swift
//  iChatGPT
//
//  Created by HTC on 2022/12/8.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import SwiftUI
import MarkdownText

struct AIChatView: View {
    
    @State private var isScrollListTop: Bool = false
    @State private var isSettingsPresented: Bool = false
    @StateObject private var chatModel = AIChatModel(roomID: ChatRoomStore.shared.lastRoomId())
    @StateObject private var inputModel = AIChatInputModel()
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { proxy in
                    List {
                        ForEach(chatModel.contents, id: \.datetime) { item in
                            Section(header: Text(item.datetime)) {
                                VStack(alignment: .leading) {
                                    HStack(alignment: .top) {
                                        AvatarImageView(url: item.userAvatarUrl)
                                        MarkdownText(item.issue.replacingOccurrences(of: "\n", with: "\n\n"))
                                            .padding(.top, 3)
                                    }
                                    Divider()
                                    HStack(alignment: .top) {
                                        Image("chatgpt-icon")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .cornerRadius(5)
                                            .padding(.trailing, 10)
                                        if item.isResponse {
                                            MarkdownText(item.answer ?? "")
                                        } else {
                                            ProgressView()
                                            Text("Loading..".localized())
                                                .padding(.leading, 10)
                                        }
                                    }
                                    .padding([.top, .bottom], 3)
                                }.contextMenu {
                                    ChatContextMenu(searchText: $inputModel.searchText, chatModel: chatModel, item: item)
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .onChange(of: chatModel.isScrollListBottom) { _ in
                        if let lastId = chatModel.contents.last?.datetime {
                            withAnimation {
                                proxy.scrollTo(lastId, anchor: .trailing)
                            }
                        }
                    }
                    .onChange(of: isScrollListTop) { _ in
                        if let firstId = chatModel.contents.first?.datetime {
                            withAnimation {
                                proxy.scrollTo(firstId, anchor: .leading)
                            }
                        }
                    }
                }
                
                Spacer()
                ChatInputView(searchText: $inputModel.searchText, chatModel: chatModel)
                    .padding([.leading, .trailing], 12)
            }
            .markdownHeadingStyle(.custom)
            .markdownQuoteStyle(.custom)
            .markdownCodeStyle(.custom)
            .markdownInlineCodeStyle(.custom)
            .markdownOrderedListBulletStyle(.custom)
            .markdownUnorderedListBulletStyle(.custom)
            .markdownImageStyle(.custom)
            .navigationTitle("OpenAI ChatGPT")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                HStack {
                    addButton
            })
            .sheet(isPresented: $isSettingsPresented) {
                ChatAPISettingView(isKeyPresented: $isSettingsPresented, chatModel: chatModel)
            }
            .sheet(isPresented: $inputModel.isShowAllChatRoom) {
                ChatHistoryListView(isKeyPresented: $inputModel.isShowAllChatRoom, chatModel: chatModel, onComplete: { roomID in
                    if roomID != chatModel.roomID {
                        chatModel.resetRoom(roomID)
                        isScrollListTop.toggle()
                    }
                })
            }
            .sheet(isPresented: $inputModel.isConfigChatRoom) {
                ChatRoomConfigView(isKeyPresented: $inputModel.isConfigChatRoom)
            }
            .alert(isPresented: $inputModel.showingAlert) {
                switch inputModel.activeAlert {
                case .createNewChatRoom:
                    return CreateNewChatRoom()
                case .reloadLastQuestion:
                    return ReloadLastQuestion()
                case .clearAllQuestion:
                    return ClearAllQuestion()
                }
            }
            .onChange(of: inputModel.isScrollToChatRoomTop) { _ in
                isScrollListTop.toggle()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image("chatgpt").resizable()
                            .frame(width: 25, height: 25)
                        Text("ChatGPT").font(.headline)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .environmentObject(inputModel)
    }
    
    private var addButton: some View {
        Button(action: {
            isSettingsPresented.toggle()
        }) {
            HStack {
                if #available(iOS 15.4, *) {
                    Image(systemName: "key.viewfinder").imageScale(.large)
                } else {
                    Image(systemName: "key.icloud").imageScale(.large)
                }
            }.frame(height: 40)
        }
    }
}

// MARK: - Handle Input Toolbar Event
extension AIChatView {
    
    func CreateNewChatRoom() -> Alert {
        Alert(
            title: Text("打开一个新的对话"),
            message: Text("当前的对话记录将会保存和关闭，并创建一个新的聊天对话。"),
            primaryButton: .default(Text("创建")) {
                chatModel.resetRoom(nil)
            },
            secondaryButton: .cancel()
        )
    }
    
    func ReloadLastQuestion() -> Alert {
        Alert(
            title: Text("重新提问"),
            message: Text("重新请求最后一个问题。"),
            primaryButton: .default(Text("确定")) {
                if let issue = chatModel.contents.last?.issue {
                    chatModel.getChatResponse(prompt: issue)
                }
            },
            secondaryButton: .cancel()
        )
    }
    
    func ClearAllQuestion() -> Alert {
        Alert(
            title: Text("清空当前对话"),
            message: Text("清空当前对话和删除保存的对话记录。"),
            primaryButton: .destructive(Text("清空")) {
                chatModel.contents.removeAll()
            },
            secondaryButton: .cancel()
        )
    }
}

// MARK: Avatar Image View
struct AvatarImageView: View {
    let url: String
    
    var body: some View {
        Group {
            ImageLoaderView(urlString: url) {
                Color(.tertiarySystemGroupedBackground)
            } image: { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
            }
        }
        .cornerRadius(5)
        .frame(width: 25, height: 25)
        .padding(.trailing, 10)
    }
}

struct AIChatView_Previews: PreviewProvider {
    static var previews: some View {
        AIChatView()
    }
}
