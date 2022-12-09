//
//  Dates.swift
//  iChatGPT
//
//  Created by HTC on 2022/12/8.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import Foundation

extension Date {
    
    public func currentDateString(_ dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        let dateTimeString = formatter.string(from: self)
        return dateTimeString
    }
}
