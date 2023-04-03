//
//  ChatHistoryListView.swift
//  iChatGPT
//
//  Created by HTC on 2023/4/1.
//  Copyright © 2023 37 Mobile Games. All rights reserved.
//

import SwiftUI


struct ChatHistoryListView: View {
    
    @Binding var isKeyPresented: Bool
    @StateObject var chatModel: AIChatModel
    var onComplete: (String) -> Void
    
    @State private var chatItems: [ChatRoom] = ChatRoomStore.shared.chatRooms().reversed()
    
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: ChatRoom?
    
    var body: some View {
        NavigationView {
            List {
                chatList
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Chat"),
                    message: Text("Are you sure you want to delete this chat?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let item = itemToDelete {
                            deleteChat(item: item)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Chat History")
            .toolbar {
                Button(action: onCloseButtonTapped) {
                    Image(systemName: "xmark.circle").imageScale(.large)
                }
            }
        }
    }
    
    @ViewBuilder
    var chatList: some View {
        if #available(iOS 15, *) {
            ForEach(chatItems, id: \.roomID) { item in
                chatRow(for: item)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            itemToDelete = item
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
            }
            .onDelete(perform: deleteChat)
        } else {
            ForEach(chatItems, id: \.roomID) { item in
                chatRow(for: item)
            }
            .onDelete(perform: deleteChat)
        }
    }
    
    private func chatRow(for item: ChatRoom) -> some View {
        HStack {
            
            Image("chatgpt-icon")
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(5)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                Text(item.roomID.formatTimestamp())
                    .font(.headline)
                    .padding(.bottom, 5)
                
                Text(ChatMessageStore.shared.lastMessage(item.roomID)?.issue ?? "无对话记录")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                
                Spacer().height(10)
                
                Text(" \(ChatMessageStore.shared.messages(forRoom: item.roomID).count) ")
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color.blue.opacity(0.8))
                    .clipShape(Capsule())
                
                Spacer()
                
                Text(ChatMessageStore.shared.lastMessage(item.roomID)?.datetime ?? "")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onComplete(item.roomID)
            onCloseButtonTapped()
        }
    }
    
    private func deleteChat(item: ChatRoom) {
        if let index = chatItems.firstIndex(where: { $0.roomID == item.roomID }) {
            chatItems.remove(at: index)
            ChatRoomStore.shared.removeChatRoom(roomID: item.roomID)
            // check current room
            if item.roomID == chatModel.roomID {
                chatModel.resetRoom(ChatRoomStore.shared.lastRoomId())
            }
            
        }
    }
    
    private func deleteChat(at offsets: IndexSet) {
        for index in offsets {
            itemToDelete = chatItems[index]
            showingDeleteAlert = true
        }
    }
    
    private func onCloseButtonTapped() {
        isKeyPresented = false
    }
}

struct ChatHistoryListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatHistoryListView(isKeyPresented: .constant(true), chatModel: AIChatModel(roomID: nil), onComplete: {_ in })
    }
}
