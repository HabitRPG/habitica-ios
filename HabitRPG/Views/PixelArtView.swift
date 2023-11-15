//
//  PixelArtView.swift
//  Habitica
//
//  Created by Phillip Thelen on 13.11.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Kingfisher

struct PixelArtView: View {
    let source: Source?
    
    init(source: Source?) {
        self.source = source
    }
    
    init(name: String) {
        if let url = ImageManager.buildImageUrl(name: name) {
            self.source = Source.network(url)
        } else {
            self.source = nil
        }
    }
    
    var body: some View {
        KFImage(source: source).resizable().interpolation(.none)
    }
    
}
