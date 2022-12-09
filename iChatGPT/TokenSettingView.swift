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
    @State private var text: String = ""
    @State private var error: String = ""
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    private let appSubVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
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
                Text("Session Token:")
                MultilineTextField("请输入 Session Token", text: $text, maxHeight: 300, onCommit: {
                    #if DEBUG
                    print("Final text: \(text)")
                    #endif
                })
                .overlay(RoundedRectangle(cornerRadius: 5)
                .stroke(Color.secondary))
                
                if error.count > 0 && text.count == 0 {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .padding([.leading, .trailing], 20)
            
            Spacer()
            Button(action: {
                if text.isEmpty {
                    error = "Session Token 不能为空！"
                } else {
                    UserDefaults.standard.set(text, forKey: ChatGPTSessionTokenKey)
                    isAddPresented = false
                    chatModel.isRefreshSession = true
                }
            }) {
                Text("确认")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .padding([.leading, .trailing], 20)
                    .padding([.top, .bottom], 6)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue, lineWidth: 1))
            }.padding([.top, .bottom], 25)
            
            Spacer()
            
            Text("v \(appVersion ?? "") (\(appSubVersion ?? ""))")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
            
            Text("开发者：37手游iOS技术运营团队\nGitHub 开源：https://github.com/37iOS/iChatGPT")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
        }
    }
}

//struct TokenSettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        TokenSettingView()
//    }
//}
