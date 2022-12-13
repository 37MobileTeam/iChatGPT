//
//  ImageLoaderView.swift
//  iChatGPT
//
//  Created by HTC on 2022/12/10.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import Foundation
import SwiftUI

struct ImageLoaderView<Placeholder: View, ConfiguredImage: View>: View {
    
    @ObservedObject var imageLoader: ImageLoader
    @State var imageData: UIImage?
    
    private var imageUrl: String
    private let placeholder: () -> Placeholder
    private let image: (Image) -> ConfiguredImage

    init(
        urlString: String,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder image: @escaping (Image) -> ConfiguredImage
    ) {
        self.imageUrl = urlString
        self.placeholder = placeholder
        self.image = image
        
        if #available(iOS 15.0, *) {
            imageLoader = ImageLoader(urlString: "")
        } else {
            imageLoader = ImageLoader(urlString: urlString)
        }
    }
    
    @ViewBuilder private var imageContent: some View {
        if let data = imageData {
            image(Image(uiImage: data))
        } else {
            placeholder()
        }
    }
    
    var body: some View {
        if #available(iOS 15.0, *), let url = URL(string: imageUrl) {
            AsyncImage(
                url: url,
                content: { img in
                    image(img)
                },
                placeholder: {
                    placeholder()
                }
            )
        } else {
            imageContent
                .onReceive(imageLoader.$image) { imageData in
                    if imageData != nil {
                        self.imageData = imageData
                    }
                }
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }
        task.resume()
    }
}
