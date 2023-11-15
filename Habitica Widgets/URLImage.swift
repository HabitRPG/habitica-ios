//
//  URLImage.swift
//  Habitica WidgetsExtension
//
//  Created by Phillip Thelen on 07.10.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Combine
import Foundation

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let url: URL

    private var cancellable: AnyCancellable?

    init(url: URL) {
        self.url = url
    }

    deinit {
        cancel()
    }
    
    func load() {
            cancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { UIImage(data: $0.data) }
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.image = $0 }
        }
        
    func cancel() {
        cancellable?.cancel()
    }
}

struct AsyncImage: View {
    let url: URL

    init(url: URL) {
        self.url = url
    }

    var body: some View {
        Group {
            if let imageData = try? Data(contentsOf: url),
           let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center).clipShape(ContainerRelativeShape().inset(by: 10))
          } else {
           Image("placeholder-image")
          }
        }
    }
}
