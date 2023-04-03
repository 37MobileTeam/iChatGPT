//
//  ChatRoomConfigView.swift
//  iChatGPT
//
//  Created by HTC on 2023/4/1.
//  Copyright © 2023 37 Mobile Games. All rights reserved.
//

import SwiftUI

struct ChatRoomConfigView: View {
    
    @Binding var isKeyPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Coming soon..".localized()).font(.title2)
            }
            .navigationTitle("Room Settings".localized())
            .toolbar {
                Button(action: onCloseButtonTapped) {
                    Image(systemName: "xmark.circle").imageScale(.large)
                }
            }
        }
    }
    
    private func onCloseButtonTapped() {
        isKeyPresented = false
    }
}


struct ChatRoomConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomConfigView(isKeyPresented: .constant(true))
    }
}

