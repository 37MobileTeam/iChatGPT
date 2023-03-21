//
//  ReverseScrollView.swift
//  ChatGPT
//
//  Created by Peter on 2023/3/19.
//

import SwiftUI

struct ScrollableView<Content: View>: View {
    @State var contentHeight: CGFloat = 0
    @State var scrollOffset: CGFloat = 0
    @State var currentOffset: CGFloat = 0
    @State var isAnimation = false
    
    var content: () ->  Content
    
    var body: some View {
        GeometryReader { proxy in
            content()
                .modifier(ViewHeightKey())
                .onPreferenceChange(ViewHeightKey.self) { height in
                    contentHeight = height
                }
                .frame(height: proxy.size.height)
                .offset(y: offset(proxy.size.height, innerHeight: contentHeight))
                .clipped()
                .animation(.spring(), value: isAnimation)
                .gesture(
                    DragGesture()
                        .onChanged(onDragChange(_:))
                        .onEnded({ value in
                            onDragEnd(value, outheight: proxy.size.height)
                        })
                )
        }
    }
    
    private func offset(_ outheight: CGFloat, innerHeight: CGFloat) -> CGFloat {
        let totalOffset = currentOffset + scrollOffset
        print("\n>>> total height: \(innerHeight)")
        print(">>> total offset: \(totalOffset)")
        print(">>> outer height: \(outheight)")
        
        let offset: CGFloat
        if innerHeight < outheight {
            offset = -(outheight / 2 - innerHeight / 2 - totalOffset)
        }   else    {
            offset = -((innerHeight / 2.0 - outheight / 2.0) - totalOffset)
        }
        
        print(">>> offset: \(offset)")
        return offset
    }
    
    private func onDragChange(_ value: DragGesture.Value) {
        scrollOffset = value.location.y - value.startLocation.y
    }
    
    private func onDragEnd(_ value: DragGesture.Value, outheight: CGFloat) {
        let offset = value.translation.height
        let topLimit = contentHeight - outheight
        if topLimit < 0 {
            currentOffset = 0
        }   else    {
            if currentOffset + offset < 0 {
                currentOffset = 0
            }   else if currentOffset + offset > topLimit {
                currentOffset = topLimit
            }   else    {
                currentOffset += offset
            }
        }
        scrollOffset = 0
        isAnimation.toggle()
    }
}

struct ReverseScrollView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollableView {
            VStack {
                ForEach(0..<10) { index in
                    Text("message \(index + 1)")
                }
            }
        }
    }
}
