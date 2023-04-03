
import Foundation
import OpenAI

let ChatGPTOpenAIKey = "ChatGPTOpenAIKey"
let ChatGPTModelName = "ChatGPTModelName"

// MARK: - Model
struct AIChat: Codable {
    let datetime: String
    var issue: String
    var answer: String?
    var isResponse: Bool = false
    var model: String
    var userAvatarUrl: String
    //var botAvatarUrl: String = "https://chat.openai.com/apple-touch-icon.png"
}


@MainActor
class AIChatModel: ObservableObject {
    
    /// 是否滚动到底部
    @Published var isScrollListBottom: Bool = true
    /// 请求是否带上之前的提问和问答
    @Published var isSendContext: Bool = true
    /// 对话内容模型
    @Published var contents: [AIChat] = [] {
        didSet {
            saveMessagesData()
        }
    }
    /// room id
    var roomID: String
    /// api model
    var apiModel: String {
        didSet {
            saveRoomConfigData()
        }
    }
    /// 更新 token 时更新请求的会话
    var isRefreshSession: Bool = false
    private var bot: Chatbot?
    
    init(roomID: String?) {
        let roomID = roomID ?? String(Int(Date().timeIntervalSince1970))
        self.roomID = roomID
        if let room = ChatRoomStore.shared.chatRoom(roomID) {
            apiModel = room.model ?? UserDefaults.standard.string(forKey: ChatGPTModelName) ?? "gpt-3.5-turbo"
            let messages = ChatMessageStore.shared.messages(forRoom: roomID)
            contents.append(contentsOf: messages)
        } else {
            apiModel = UserDefaults.standard.string(forKey: ChatGPTModelName) ?? "gpt-3.5-turbo"
            ChatRoomStore.shared.addChatRoom(ChatRoom(roomID: roomID))
        }
        loadChatbot()
    }
    
    func resetRoom(_ roomID: String?) {
        let newRoomID = roomID ?? String(Int(Date().timeIntervalSince1970))
        self.roomID = newRoomID
        self.contents = ChatMessageStore.shared.messages(forRoom: newRoomID)
        apiModel = UserDefaults.standard.string(forKey: ChatGPTModelName) ?? "gpt-3.5-turbo"
        let room = ChatRoomStore.shared.chatRoom(newRoomID) ?? ChatRoom(roomID: newRoomID)
        ChatRoomStore.shared.addChatRoom(room)
        loadChatbot()
    }
    
    func getChatResponse(prompt: String){
        if isRefreshSession {
            loadChatbot()
        }
        let index = contents.count
        let userAvatarUrl = self.bot?.getUserAvatar() ?? ""
        let model = UserDefaults.standard.string(forKey: ChatGPTModelName) ?? "gpt-3.5-turbo"
        var chat = AIChat(datetime: Date().currentDateString(), issue: prompt, model: model, userAvatarUrl: userAvatarUrl)
        contents.append(chat)
        isScrollListBottom.toggle()
        
        self.bot?.getChatGPTAnswer(prompts: contents, sendContext: isSendContext) { answer in
            let content = answer
            DispatchQueue.main.async { [self] in
                chat.answer = content
                chat.isResponse = true
                contents[index] = chat
            }
        }
    }
    
    func loadChatbot() {
        isRefreshSession = false
        let chatGPTOpenAIKey = UserDefaults.standard.string(forKey: ChatGPTOpenAIKey) ?? ""
        bot = Chatbot( openAIKey: chatGPTOpenAIKey)
    }
    
    func saveMessagesData() {
        ChatMessageStore.shared.updateMessages(roomID: roomID, chats: contents)
    }
    
    func saveRoomConfigData() {
        
    }
}
