
import Foundation
import OpenAI
import Combine

let ChatGPTOpenAIKey = "ChatGPTOpenAIKey"
let ChatGPTModelName = "ChatGPTModelName"

// MARK: - Welcome1
struct AIChat: Codable {
    let datetime: String
    var issue: String
    var answer: String?
    var isResponse: Bool = false
    var userAvatarUrl: String
    var botAvatarUrl: String = "https://chat.openai.com/apple-touch-icon.png"
    var model: String
    
}


@MainActor
class AIChatModel: ObservableObject {
    
    var isRefreshSession: Bool = false
    @Published var contents: [AIChat] = []
    private var bot: Chatbot?
    let newMessageSubject = PassthroughSubject<AIChat, Never>()
    
    init(contents: [AIChat]) {
        self.contents = contents
        loadChatbot()
    }
    
    func getChatResponse(prompt: String){
        if isRefreshSession {
            loadChatbot()
        }
        let index = contents.count
        let userAvatarUrl = self.bot?.getUserAvatar() ?? ""
        let model = UserDefaults.standard.string(forKey: ChatGPTModelName) ?? "gpt-3.5-turbo"
        var chat = AIChat(datetime: Date().currentDateString(), issue: prompt, userAvatarUrl: userAvatarUrl, model: model)
        contents.append(chat)

        self.bot?.getChatGPTAnswer(prompts: contents){answer in
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
}
