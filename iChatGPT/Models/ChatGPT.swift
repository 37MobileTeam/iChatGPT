//
//  ChatGPT.swift
//  iChatGPT
//
//  Created by HTC on 2022/12/8.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import Foundation
import Combine


class Chatbot {
	
	let apUrl = "https://chat.openai.com/"
    let cfClearanceKey = "cf_clearance"
	let sessionTokenKey = "__Secure-next-auth.session-token"
	let timeout = 20
    /// Code=-1001 "The request timed out."
    /// Code=-1017 "cannot parse response"
    /// Code=-1009 "The Internet connection appears to be offline."
    let errorCodes = [-1001, -1017, -1009]
    var sessionToken: String
    var cfClearance: String
	var userAgent: String?
	var authorization = ""
	var conversationId = ""
	var parentId = ""
	var userAvatarUrl = ""
	
    init(sessionToken: String, cfClearance: String, userAgent: String?) {
		self.sessionToken = sessionToken
        self.cfClearance = cfClearance
        self.userAgent = userAgent
        Task {
            await refreshSession()
        }
	}
	
	private func headers() -> [String: String] {
		return [
			"Host": "chat.openai.com",
			"Accept": "text/event-stream",
            "Authorization": "Bearer \(self.authorization)",
			"Cookie": "\(cfClearanceKey)=\(self.cfClearance)",
			"Content-Type": "application/json",
            "User-Agent": self.userAgent ?? "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Safari/605.1.15",
			"X-Openai-Assistant-App-Id": "",
			"Connection": "keep-alive",
			"Accept-Language": "zh-CN,zh-Hans;en-US,en;q=0.9",
			"Referer": "https://chat.openai.com/chat",
		]
	}
	
    private func getPayload(prompt: String) -> [String: Any] {
		var body = [
			"action": "next",
			"messages": [
				[
					"id": "\(UUID().uuidString)",
					"role": "user",
					"content": ["content_type": "text", "parts": [prompt]],
				]
			],
			"parent_message_id": "\(self.parentId)",
			"model": "text-davinci-002-render",
		] as [String: Any]
		if !self.conversationId.isEmpty {
			body["conversation_id"] = self.conversationId
		}
		return body
	}
    
    func getUserAvatar() -> String {
        userAvatarUrl
    }
	
	func refreshSession(retry: Int = 1) async {
        let cookies = "\(cfClearanceKey)=\(self.cfClearance); \(sessionTokenKey)=\(self.sessionToken)"
		let url = self.apUrl + "api/auth/session"
		let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Safari/605.1.15"
		var request = URLRequest(url: URL(string: url)!)
		request.httpMethod = "GET"
        request.addValue(self.userAgent ?? userAgent, forHTTPHeaderField: "User-Agent")
		request.addValue(cookies, forHTTPHeaderField: "Cookie")
        request.httpShouldHandleCookies = true
		do {
			let (data, response) = try await URLSession.shared.data(for: request)
			let json = try JSONSerialization.jsonObject(with: data, options: [])
			if let dictionary = json as? [String: Any] {
				if let accessToken = dictionary["accessToken"] as? String {
					authorization = accessToken
				}
                if let user = dictionary["user"] as? [String: Any],
                    let image = user["image"] as? String {
                    userAvatarUrl = image
                }
			}
			guard let response = response as? HTTPURLResponse,
				  let cookies = HTTPCookieStorage.shared.cookies(for: response.url!) else {
				print("刷新会话失败: <r>HTTP:\(response)")
				return
			}
			for cookie in cookies {
				if cookie.name == sessionTokenKey {
					self.sessionToken = cookie.value
                    UserDefaults.standard.set(cookie.value, forKey: ChatGPTSessionTokenKey)
				}
			}
		}
		catch {
            if let err = error as NSError?, errorCodes.contains(err.code), retry > 0 {
                return await refreshSession(retry: retry - 1)
            }
			print("刷新会话失败: <r>HTTP:\(error)")
		}
	}
	
    func getChatResponse(prompt: String, retry: Int = 1) async -> String {
		if self.authorization.isEmpty {
			await refreshSession()
		}
		
		let url = self.apUrl + "backend-api/conversation"
		var request = URLRequest(url: URL(string: url)!)
		request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers()
		let dict = getPayload(prompt: prompt)
		do {
			let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
			request.httpBody = jsonData
			let (data, response) = try await URLSession.shared.data(for: request)
			guard let response = response as? HTTPURLResponse else {
				let err = "非预期的响应内容:  <r>HTTP:\(response)"
				print(err)
				return err
			}
			
			if response.statusCode == 429 {
				return "请求过多，请放慢速度"
			}
            
            if response.statusCode == 401, retry > 0 {
                // Incorrect API key provided: Bearer. or Authentication token has expired
                return await getChatResponse(prompt: prompt, retry: retry - 1)
            }
			
            guard let text = String(data: data, encoding: .utf8) else {
                return "非预期的响应内容: 内容读取失败~"
            }
            
            if response.statusCode != 200 {
                let err = "非预期的响应内容:  <r>HTTP:\(response.statusCode)</r> \(text)"
                print(err)
                return err
            }
            
			let lines = text.components(separatedBy: "\n")
			// 倒数第四行，第6个字符后开始
			let str = lines[lines.count - 5]
            #if DEBUG
			print(str)
            #endif
			let jsonString = str.suffix(from: str.index(str.startIndex, offsetBy: 6))
			guard let jsondata = jsonString.data(using: .utf8) else {
				return ""
			}
			let json = try JSONSerialization.jsonObject(with: jsondata, options: [])
			guard let dictionary = json as? [String: Any],
					let conversation_id = dictionary["conversation_id"] as? String,
					let message = dictionary["message"] as? [String: Any],
					let parent_id = message["id"] as? String,
					let content = message["content"] as? [String: Any],
					let texts = content["parts"] as? [String],
					let parts = texts.last
					else {
				return "解析错误~"
			}
			self.parentId = parent_id
			self.conversationId = conversation_id
			return parts
		}
		catch {
            if let err = error as NSError?, errorCodes.contains(err.code), retry > 0 {
                return await getChatResponse(prompt: prompt, retry: retry - 1)
            }
			return "请求异常：\(error)"
		}
	}
}
