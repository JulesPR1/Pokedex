//
//  ImageLoader.swift
//  Pokedex
//
//  Created by Jules PASCUAL-RAMON on 21/09/2023.
//

import Foundation
import SwiftUI

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    func loadImage(from url: URL?) {
        guard let url = url else { return }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let data = data, let loadedImage = UIImage(data: data) {
                    self.image = loadedImage
                }
            }
        }.resume()
    }
}

struct AsyncImageView: View {
    @StateObject private var imageLoader = ImageLoader()
    private var url: URL?
    
    init(url: URL?) {
        self.url = url
    }
    
    var body: some View {
        if let image = imageLoader.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .onAppear {
                    if imageLoader.image == nil {
                        imageLoader.loadImage(from: url)
                    }
                }
        } else if imageLoader.isLoading {
            ProgressView()
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
        }
    }
}
