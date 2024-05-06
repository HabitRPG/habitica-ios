//
//  CTAFooterView.swift
//  Habitica
//
//  Created by Phillip Thelen on 06.05.24.
//  Copyright © 2024 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct CTAFooterView: View {
    let type: String
    let hasItems: Bool
    
    private var image: UIImage {
        switch type {
        case "background":
            return Asset.Empty.backgrounds.image
        case "customizations":
            return Asset.Empty.customizations.image
        default:
            return Asset.Empty.customizations.image
        }
    }
    
    private func splitDescription() -> [String] {
        let text = (hasItems ? L10n.Empty.wantMoreItemsDescription : L10n.Empty.noItemsDescription)
        var textElements = [String]()
        if let range = text.range(of: L10n.customizationShop) {
            textElements.append(String(text.prefix(upTo: range.lowerBound)))
            textElements.append(String(text[range]))
            textElements.append(String(text.suffix(from: range.upperBound)))
        } else {
            textElements.append(text)
        }
        return textElements
    }
    
    @ViewBuilder
    private func description() -> some View {
        let textElements = splitDescription()
        if textElements.count == 3 {
            Group {
                Text(textElements[0]) +
                Text(textElements[1]).foregroundColor(Color(ThemeService.shared.theme.tintColor)) +
                Text(textElements[2])
            }
        } else {
            Text(textElements.first ?? "")
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Image(uiImage: image).padding(.bottom, 8)
            Text(hasItems ? L10n.Empty.wantMoreItems : L10n.Empty.noItems)
                .fontWeight(.semibold)
                .foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
            description()
                .foregroundColor(Color(ThemeService.shared.theme.secondaryTextColor))
                .multilineTextAlignment(.center)
        }
        .font(.system(size: 13))
        .ignoresSafeArea()
        .onTapGesture {
            RouterHandler.shared.handle(.customizationShop)
        }
        .frame(maxWidth: 260)
        .padding(.top, 50)
    }
}

#Preview {
    Group {
        CTAFooterView(type: "background", hasItems: true)
        CTAFooterView(type: "background", hasItems: false)
        CTAFooterView(type: "hair", hasItems: true)
    }
}
