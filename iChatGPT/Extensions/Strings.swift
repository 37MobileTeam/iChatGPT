//
//  Strings.swift
//  iChatGPT
//
//  Created by HTC on 2022/12/8.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import Foundation
import SwiftUI

extension String {
    
    /// 复制文本到剪贴板
    public func copyToClipboard() {
        guard self.count > 0 else {
            return
        }

        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(self, forType: .string)
        #else
        UIPasteboard.general.string = self
        #endif
    }
    
    public func localized() -> String {
        let string = NSLocalizedString(self, comment: self)
        return string
    }
}
