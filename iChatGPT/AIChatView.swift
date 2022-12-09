//
//  AIChatView.swift
//  iChatGPT
//
//  Created by HTC on 2022/12/8.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import SwiftUI
import MarkdownUI

struct AIChatView: View {
    
    @State private var isAddPresented: Bool = false
    @State private var searchText = ""
    @StateObject private var chatModel = AIChatModel(contents: [])
    
    var body: some View {
        NavigationView {
            Group {
                List {
                    ForEach(chatModel.contents, id: \.datetime) { item in
                        Section(header: Text(item.datetime)) {
                            VStack {
                                Markdown(item.issue)
                                Divider()
                                if item.isResponse {
                                    // Text(.init(item.answer))
                                    Markdown(item.answer ?? "")
                                } else {
                                    HStack {
                                        ProgressView()
                                        Text("请求中..")
                                            .padding(.leading, 10)
                                    }
                                }
                            }.contextMenu {
                                ChatContextMenu(searchText: $searchText, chatModel: chatModel, item: item)
                            }
                        }
                    }
                }.listStyle(InsetGroupedListStyle())
                Spacer()
                ChatInputView(searchText: $searchText, chatModel: chatModel).padding([.leading, .trailing], 12)
            }
            .navigationTitle("OpenAI ChatGPT")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                HStack {
                    addButton
            })
            .sheet(isPresented: $isAddPresented, content: {
                TokenSettingView(isAddPresented: $isAddPresented, chatModel: chatModel)
            })
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
    }
    
    private var addButton: some View {
        Button(action: {
            isAddPresented = true
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

struct AIChatView_Previews: PreviewProvider {
    static var previews: some View {
        AIChatView()
    }
}
