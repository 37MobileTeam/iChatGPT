//
//  View.swift
//  iChatGPT
//
//  Created by HTC on 2023/4/16.
//  Copyright © 2023 37 Mobile Games. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    
    /// 当用户点击其他区域时隐藏软键盘
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
