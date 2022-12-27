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
    @State private var sessionToken: String = ""
    @State private var cfClearance: String = ""
    @State private var userAgent: String = ""
    @State private var sError: String = ""
    @State private var cError: String = ""
    @State private var uError: String = ""
    
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
                if #available(iOS 15.0, *) {
                    TextField(" 请输入 session_token", text: $sessionToken)
                        .frame(height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.tertiaryLabel)))
                        .submitLabel(.done)
                } else {
                    TextField(" 请输入 session_token", text: $sessionToken)
                        .frame(height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.tertiaryLabel)))
                }
                
                if sError.count > 0 && sessionToken.isEmpty {
                    Text(sError)
                        .foregroundColor(.red)
                }
                
                Text("Cf Clearance:")
                    .padding(.top, 15)
                if #available(iOS 15.0, *) {
                    TextField(" 请输入 cf_clearance", text: $cfClearance)
                        .frame(height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.secondary))
                        .submitLabel(.done)
                } else {
                    TextField(" 请输入 cf_clearance", text: $cfClearance)
                        .frame(height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.secondary))
                }
                
                if cError.count > 0 && cfClearance.isEmpty {
                    Text(cError)
                        .foregroundColor(.red)
                }
                
                Text("User Agent:")
                    .padding(.top, 15)                
                if #available(iOS 15.0, *) {
                    TextField(" 请输入 user_agent", text: $userAgent)
                        .frame(height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.secondary))
                        .submitLabel(.done)
                } else {
                    TextField(" 请输入 user_agent", text: $userAgent)
                        .frame(height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.secondary))
                }
                
                if uError.count > 0 && userAgent.isEmpty {
                    Text(uError)
                        .foregroundColor(.red)
                        .padding(.bottom, 10)
                }
            }
            .padding([.leading, .trailing], 20)
            
            Spacer()
            Button(action: {
                guard !sessionToken.isEmpty else {
                    sError = "Session Token 不能为空！"
                    return
                }
                guard !cfClearance.isEmpty else {
                    cError = "Cf Clearance 不能为空！"
                    return
                }
                guard !userAgent.isEmpty else {
                    uError = "User Agent 不能为空！"
                    return
                }
                
                UserDefaults.standard.set(sessionToken, forKey: ChatGPTSessionTokenKey)
                UserDefaults.standard.set(cfClearance, forKey: ChatGPTCfClearanceKey)
                UserDefaults.standard.set(userAgent, forKey: ChatGPTUserAgentKey)
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
            
            Text("v \(appVersion ?? "") (\(appSubVersion ?? ""))")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
            
            Text("开发者：37手游iOS技术运营团队\nGitHub 开源：https://github.com/37iOS/iChatGPT")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 25)
        }
    }
}

//struct TokenSettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        TokenSettingView()
//    }
//}
