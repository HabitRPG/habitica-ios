//
//  PixelArtView.swift
//  Habitica
//
//  Created by Phillip Thelen on 13.11.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Kingfisher

struct PixelArtView: UIViewRepresentable {
    var name: String?
    var source: Source?
    
    func makeUIView(context: Context) -> NetworkImageView {
        let view = NetworkImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func updateUIView(_ uiView: NetworkImageView, context: Context) {
        uiView.contentMode = .scaleAspectFit
        if let name = name {
            uiView.setImagewith(name: name)
        } else if let source = source {
            uiView.kf.setImage(with: source)
        }
    }
}
