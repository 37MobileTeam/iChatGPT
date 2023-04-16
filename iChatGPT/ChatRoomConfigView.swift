//
//  ChatRoomConfigView.swift
//  iChatGPT
//
//  Created by HTC on 2023/4/1.
//  Copyright © 2023 37 Mobile Games. All rights reserved.
//

import SwiftUI
import Combine
import SwiftUIX

struct ChatRoomConfigView: View {
    
    @Binding var isKeyPresented: Bool
    @StateObject var chatModel: AIChatModel
    
    @State var roomName: String = ""
    @State var prompt: String = ""
    @State var temperature: String = ""
    @State var historyCount: String = ""
    @State var selectedModel: Int = 0
    @State var isDirty: Bool = false
    @State var showingAlert: Bool = false
    @State var alertMessage: String = ""
    
    init(isKeyPresented: Binding<Bool>, chatModel: AIChatModel) {
        _isKeyPresented = isKeyPresented
        _chatModel = StateObject(wrappedValue: chatModel)

        let room = ChatRoomStore.shared.chatRoom(chatModel.roomID)
        _roomName = State(initialValue: room?.roomName ?? room?.roomID.formatTimestamp() ?? "")
        _prompt = State(initialValue: room?.prompt ?? "")
        _temperature = State(initialValue: "\(room?.temperature ?? 0.7)")
        _historyCount = State(initialValue: "\(room?.historyCount ?? 0)")
        _isDirty = State(initialValue: false)
        
        if let savedModelName = room?.model,
           let index = kAPIModels.firstIndex(of: savedModelName) {
            _selectedModel = State(initialValue: index)
        } else {
            _selectedModel = State(initialValue: 0)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ConfigCellView(title: "Room Name".localized(),
                               subtitle: "",
                               value: $roomName,
                               description: "The name of the room".localized())
                ConfigCellView(title: "Prompt".localized(), subtitle: "Prompt description.".localized(), value: $prompt, description: "Prompt text to generate contextual information for the corresponding text.".localized())
                ConfigCellView(title: "Temperature".localized(), subtitle: "What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.".localized(), value: $temperature, description: "The default temperature is 0.7".localized())
                ConfigCellView(title: "Chat History".localized(), subtitle: "How much context information is carried when sending a dialog.".localized(), value: $historyCount, description: "Default is the last 3 conversations.".localized())
                
                Section(header: Text("API Model".localized())) {
                    Picker(selection: $selectedModel, label: Text("Select Room API Model".localized())) {
                        ForEach(0..<kAPIModels.count, id: \.self) {
                            Text(kAPIModels[$0])
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Room Settings".localized()))
            .navigationBarItems(
                trailing:
                    HStack {
                        Button(action: onSaveButtonTapped, label: {
                            Text("Save".localized()).bold()
                        }).disabled(!isDirty)

                        Button(action: onCloseButtonTapped) {
                            Image(systemName: "xmark.circle").imageScale(.large)
                        }
                    }
            )
            .alert(isPresented: $showingAlert) {
                ShowAlterView()
            }
            .onChange(of: selectedModel) { _ in
                self.isDirty = true
            }
            .onChange(of: [roomName, prompt, temperature, historyCount]) { _ in
                self.isDirty = true
            }
            .gesture(
                TapGesture(count: 2).onEnded {
                    hideKeyboard()
                }
            )
        }
    }
    
    private func onSaveButtonTapped() {
        // 检查 temperature 数据格式是否符合
        guard let tempValue = Double(temperature), 0.0 <= tempValue && tempValue <= 2.0 else {
            alertMessage = "Temperature is between 0 and 2.".localized()
            showingAlert = true
            return
        }

        // 检查 historyCount 数据格式是否符合
        guard let histCountValue = Int(historyCount), histCountValue >= 0 else {
            alertMessage = "History message count must be an integer greater than or equal to 0.".localized()
            showingAlert = true
            return
        }
        
        let model = kAPIModels[selectedModel]
        let room = ChatRoom(roomID: chatModel.roomID, roomName: roomName, model: model, prompt: prompt.isEmpty ? nil : prompt, temperature: tempValue, historyCount: histCountValue)
        ChatRoomStore.shared.updateChatRoom(for: chatModel.roomID, room: room)
        self.isDirty = false
        
        alertMessage = "Settings have been updated~".localized()
        showingAlert = true
    }
    
    func ShowAlterView() -> Alert {
        Alert(
            title: Text("Tips".localized()),
            message: Text(alertMessage),
            dismissButton: .default(Text("OK".localized()))
        )
    }
    
    private func onCloseButtonTapped() {
        isKeyPresented = false
    }
}

struct ConfigCellView: View {
    let title: String
    let subtitle: String
    @Binding var value: String
    let description: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.top, 10)
            
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondaryLabel)
                    .padding(.top, 0.5)
                    .padding(.bottom, 10)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            TextView(description, text: $value, onEditingChanged: {_ in
                
            }, onCommit: {
                
            })
            .returnKeyType(.default)
            .padding(10)
            .maxHeight(90)
            .border(.blue.opacity(0.8), cornerRadius: 10)
            
            Spacer()
                .height(15)
        }
    }
}

struct ChatRoomConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomConfigView(isKeyPresented: .constant(true), chatModel:  AIChatModel(roomID: nil))
    }
}

