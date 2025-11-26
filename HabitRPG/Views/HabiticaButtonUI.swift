//
//  HabiticaButtonUI.swift
//  Habitica
//
//  Created by Phillip Thelen on 14.10.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import SwiftUI
import ReactiveSwift

struct HabiticaButtonUI<Label: View>: View {
    enum Size {
        case small
        case compact
        case normal
        
        var height: CGFloat {
            switch self {
            case .small:
                return 40
            case .compact:
                return 48
            case .normal:
                return 60
            }
        }
    }
    enum ButtonType {
        case solid
        case bordered
    }
    let label: Label
    var color: Color = .clear
    var size: Size = .normal
    var type: ButtonType = .solid
    var onTap: (() -> Void)
    
    private func getforegroundStyle() -> Color {
        if type == .solid {
            return color == .white ? Color(UIColor.purple400) : .white
        } else {
            return color
        }
    }
    var body: some View {
        Button(action: onTap, label: {
                label.underline(UIAccessibility.buttonShapesEnabled, color: getforegroundStyle())
                .foregroundStyle(getforegroundStyle())
                .scaledFont(size: 17, weight: .semibold)
                .padding(.vertical, 6)
                .frame(minHeight: size.height)
                .frame(maxWidth: .infinity)
        }).buttonStyle { configuration in
            if #available(iOS 26.0, *) {
                configuration.label
                    .glassEffect(
                        color != .clear ? .regular.interactive().tint(color.opacity(0.9)) : .regular.interactive())
            } else {
                configuration.label
                    .background(type == .bordered ? Color.clear : color)
                    .overlay(RoundedRectangle(cornerRadius: UIConstants.largeCornerRadius).stroke(color, lineWidth: type == .bordered ? 3 : 0))
                    .cornerRadius(UIConstants.largeCornerRadius)
            }
        }
    }
}
