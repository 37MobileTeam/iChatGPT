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
    
    @State private var isAddPresented: Bool = false
    @State private var searchText = ""
    @StateObject private var chatModel = AIChatModel(contents: [])
    
    var body: some View {
        NavigationView {
            Group {
                List {
                    ForEach(chatModel.contents, id: \.datetime) { item in
                        Section(header: Text(item.datetime)) {
                            VStack(alignment: .leading) {
                                HStack(alignment: .top) {
                                    AvatarImageView(url: item.userAvatarUrl)
                                    MarkdownText(item.issue)
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
                                ChatContextMenu(searchText: $searchText, chatModel: chatModel, item: item)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                Spacer()
                ChatInputView(searchText: $searchText, chatModel: chatModel)
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
