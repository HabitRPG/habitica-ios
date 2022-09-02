//
//  BottomSheetMenu.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.08.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation
import SwiftUI
import Kingfisher

class Dismisser: ObservableObject {
    let dismiss: () -> Void
    
    init(dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
    }
}

struct BottomSheetMenuitem<Title: View>: View {
    @Environment(\.presentationMode) private var presentationMode
    
    enum Style {
        case normal
        case destructive
        case secondary
    }

    let title: Title
    let style: Style
    let onTap: (() -> Void)
    
    init(title: Title, style: Style = .normal, onTap: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.onTap = onTap
    }
    
    var body: some View {
        HabiticaButtonUI(label: title, color: style == .normal ? .tintColor : style == .destructive ? Color(UIColor.red100) : .windowBackgroundColor, size: .compact) {
            onTap()
            presentationMode.wrappedValue.dismiss()
        }
    }
}

extension BottomSheetMenuitem where Title == Text {
    init(title: String, style: Style = .normal, onTap: @escaping () -> Void) {
        self.title = Text(title)
        self.style = style
        self.onTap = onTap
    }
}

struct BottomSheetMenu<Title: View, MenuItems: View>: View {
    var title: Title
    var iconURL: URL?
    let menuItems: MenuItems
    
    init(_ title: Title, iconURL: String? = nil, @ViewBuilder menuItems: () -> MenuItems) {
        self.title = title
        if let url = iconURL {
            self.iconURL = URL(string: url)
        }
        self.menuItems = menuItems()
      }
    init(_ title: Title, iconName: String, @ViewBuilder menuItems: () -> MenuItems) {
        self.title = title
        self.iconURL = ImageManager.buildImageUrl(name: iconName)
        self.menuItems = menuItems()
      }
    
    var body: some View {
        VStack(spacing: 16) {
            title
                .font(.headline)
                .foregroundColor(.primaryTextColor)
            if #available(iOS 14.0, *) {
                if let url = iconURL {
                    KFImage(url).frame(width: 70, height: 70)
                }
            }
            menuItems
        }.padding(.horizontal, 24)
            .padding(.top, 20)
    }
}

extension BottomSheetMenu where Title == EmptyView {
  init(@ViewBuilder menuItems: () -> MenuItems) {
      self.init(EmptyView(), menuItems: menuItems)
  }
    
    init(iconURL: String? = nil, @ViewBuilder menuItems: () -> MenuItems) {
        self.init(EmptyView(), iconURL: iconURL, menuItems: menuItems)

      }
    init(iconName: String, @ViewBuilder menuItems: () -> MenuItems) {
        self.init(EmptyView(), iconName: iconName, menuItems: menuItems)

      }
}

extension Color {
    static var primaryTextColor: Color {
            return Color(ThemeService.shared.theme.primaryTextColor)
    }
    static var secondaryTextColor: Color {
            return Color(ThemeService.shared.theme.secondaryTextColor)
    }
    static var ternaryTextColor: Color {
            return Color(ThemeService.shared.theme.ternaryTextColor)
    }
    static var tintColor: Color {
            return Color(ThemeService.shared.theme.tintColor)
    }
    static var windowBackgroundColor: Color {
            return Color(ThemeService.shared.theme.windowBackgroundColor)
    }
}
