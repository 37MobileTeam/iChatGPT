//
//  TokenSettingView.swift
//  iChatGPT
//
//  Created by HTC on 2022/12/8.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import SwiftUI

struct TokenSettingView: View {
    
    @Binding var isAddPresented: Bool
    @StateObject var chatModel: AIChatModel
    
    @State private var modelName: String = UserDefaults.standard.string(forKey: ChatGPTModelName) ?? "gpt-3.5-turbo"
    @State private var modelViewIsExpanded = false
    @State private var OpenAIKey: String = ""   //直接使用openai的key进行请求发送
    @State private var kError: String = "" // 不能为空
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    private let appSubVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    private let modelLists: [String] = ["gpt-3.5-turbo", "gpt-4"]
    
    func lastOpenAIKey() -> String? {
        
        guard let inputString = UserDefaults.standard.string(forKey: ChatGPTOpenAIKey) else { return nil }
        
        let firstThree = inputString.prefix(3)
        let lastThree = inputString.suffix(3)
        let middle = String(repeating: "*", count: inputString.count - 6)
        let outputString = "\(firstThree)\(middle)\(lastThree)"
        
        return outputString
    }
    
    
    var body: some View {
        VStack {
            HStack {
                Spacer().frame(width: 50)
                Spacer()
                Text("设置访问密钥").font(.headline).fontWeight(.bold).padding([.top, .leading], 12)
                Spacer()
                Button {
                    isAddPresented = false
                } label: {
                    Image(systemName: "xmark.circle").imageScale(.large)
                }
                .frame(width: 60, height: 60, alignment: .center)
                .padding([.top, .trailing], 8)
            
            }.padding(.bottom, 20)
            
            Spacer()
            
            VStack(alignment: .leading) {
                HStack {
                    Text("API Model：")
                    Button(action: {
                        modelViewIsExpanded.toggle()
                    }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3").imageScale(.medium)
                            Text(modelName)
                        }.frame(height: 30)
                    }
                    
                    Spacer()
                }
                
                if modelViewIsExpanded {
                    Divider()
                    ScrollView {
                        ForEach(0..<modelLists.count, id: \.self){ index in
                            HStack{
                                let model = modelLists[index]
                                if model == modelName {
                                    Text(model).padding(.horizontal).padding(.top, 10).foregroundColor(.blue)
                                } else {
                                    Text(model).padding(.horizontal).padding(.top, 10)
                                }
                                Spacer()
                                if model == modelName {
                                    Image(systemName: "checkmark").padding(.horizontal).padding(.top, 10).foregroundColor(.blue)
                                }
                            }
                            .background(Color(UIColor.systemBackground))
                            .onTapGesture {
                                let model = modelLists[index]
                                UserDefaults.standard.set(model, forKey: ChatGPTModelName)
                                withAnimation{
                                    modelName = model
                                    modelViewIsExpanded = false
                                }
                            }
                        }
                    }
                    .background(Color(UIColor.systemBackground))
                    .frame(maxHeight: 100)
                    
                    Divider()
                }
                
                Text("OpenAI Key:")
                    .padding(.top, 15)
                if #available(iOS 15.0, *) {
                    TextField(" 请输入 OpenAI Key", text: $OpenAIKey)
                        .frame(height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.secondary))
                        .submitLabel(.done)
                } else {
                    TextField(" 请输入 OpenAI Key", text: $OpenAIKey)
                        .frame(height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.secondary))
                }

                if kError.count > 0 && OpenAIKey.isEmpty {
                    Text(kError)
                        .foregroundColor(.red)
                        .padding(.bottom, 10)
                }
                
                if let lastOpenAIKey = lastOpenAIKey() {
                    Text("Last OpenAI Key:")
                        .padding(.top, 15)
                    Text("\(lastOpenAIKey)")
                        .font(.system(size: 12))
                }
            }
            .padding([.leading, .trailing], 20)
            
            Spacer()
            Button(action: {
                guard !OpenAIKey.isEmpty else{
                    kError = "OpenAI Key 不能为空"
                    return
                }
                
                UserDefaults.standard.set(OpenAIKey, forKey: ChatGPTOpenAIKey)
                isAddPresented = false
                chatModel.isRefreshSession = true
            }) {
                Text("保存")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .padding([.leading, .trailing], 20)
                    .padding([.top, .bottom], 6)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue, lineWidth: 1))
            }.padding([.top, .bottom], 25)
            
            Spacer()
            
            Group {
                Text("v \(appVersion ?? "") (\(appSubVersion ?? ""))")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
                
                Text("开发者：37手游iOS技术运营团队\nGitHub 开源：https://github.com/37iOS/iChatGPT")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                
                Text("Contributors：[@iHTCboy](https://github.com/iHTCboy) | [@AlphaGogoo](https://github.com/AlphaGogoo) | [@RbBtSn0w](https://github.com/RbBtSn0w)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 25)
            }
        }
    }
}


