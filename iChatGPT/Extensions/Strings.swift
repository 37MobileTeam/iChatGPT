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
    
    public func formatTimestamp() -> String {
        // 将时间戳字符串转换为 TimeInterval 类型
        guard let timeInterval = TimeInterval(self) else {
            return self
        }

        // 使用 TimeInterval 创建 Date 对象
        let date = Date(timeIntervalSince1970: timeInterval)

        // 使用 DateFormatter 格式化日期
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: date)
    }
}
