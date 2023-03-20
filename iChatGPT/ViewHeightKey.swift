//
//  ViewHeightKey.swift
//  ChatGPT
//
//  Created by Peter on 2023/3/19.
//

import SwiftUI

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

extension ViewHeightKey: ViewModifier {
    func body(content: Content) -> some View {
        content.background(GeometryReader(content: { proxy in
            Color.clear.preference(key: Self.self, value: proxy.size.height)
        }))
    }
}
