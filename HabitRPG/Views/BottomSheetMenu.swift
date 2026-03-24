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
    var dismissAction: (() -> Void)?
    var onDismiss: (() -> Void)?
    
    func dismiss() {
        if let action = onDismiss {
            action()
        }
        if let action = dismissAction {
            action()
        }
    }
}

struct BottomSheetMenuitem<Title: View>: View {
    @ObservedObject var themeService = ThemeService.shared
    @EnvironmentObject private var dismisser: Dismisser
    
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
        HabiticaButtonUI(label: title,
                         color: style == .normal ? Color(themeService.theme.fixedTintColor) : style == .destructive ? .red100 : Color(themeService.theme.windowBackgroundColor),
                         size: .small) {
            dismisser.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onTap()
            }
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

struct BottomSheetHeaderBar<Title: View, Left: View, Right: View>: View {
    @ObservedObject var themeService = ThemeService.shared
    var title: Title
    var leftAction: Left
    var isLeftProminent = false
    var rightAction: Right
    var isRightProminent = true
    
    var body: some View {
        HStack {
            if #available(iOS 26.0, *) {
                leftAction
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
            } else {
                leftAction
                    .clipShape(.circle)
                    .tintColor(Color(isLeftProminent ? themeService.theme.tintColor : themeService.theme.windowBackgroundColor))
            }
            Spacer()
            title
                .font(.headline)
                .foregroundStyle(Color(themeService.theme.primaryTextColor))
            Spacer()
            if #available(iOS 26.0, *) {
                rightAction
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.circle)
            } else {
                rightAction
                    .clipShape(.circle)
                    .tintColor(Color(isRightProminent ? themeService.theme.tintColor : themeService.theme.windowBackgroundColor))
            }
        }
    }
}

struct BottomSheetView<Title: View, Content: View>: View, Dismissable {
    var dismisser: Dismisser = Dismisser()
    var title: Title
    let content: Content
    var topPadding: CGFloat = 24
    var bottomPadding: CGFloat = 12

    var body: some View {
        Group {
            title.font(.headline)
            content
        }.padding(.horizontal, 20)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
    }
}

extension BottomSheetView where Title == EmptyView {
    init(dismisser: Dismisser = Dismisser(), content: Content, topPadding: CGFloat = 28, bottomPadding: CGFloat = 12) {
        self.init(dismisser: dismisser, title: EmptyView(), content: content, topPadding: topPadding, bottomPadding: bottomPadding)
    }
}

struct BottomSheetMenu<Title: View, MenuItems: View>: View, Dismissable {
    var dismisser: Dismisser = Dismisser()
    var title: Title
    var iconURL: URL?
    let menuItems: MenuItems
    
    @State private var isAppeared = false
    
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
        BottomSheetView(dismisser: dismisser, title: title, content: VStack(spacing: 16) {
                if let url = iconURL {
                    KFImage(url).interpolation(.none).frame(width: 70, height: 70)
                }
                menuItems
                .environmentObject(dismisser)
                .offset(y: isAppeared ? 0 : 35)
                .animation(.interpolatingSpring(stiffness: 300, damping: 15).delay(0.2), value: isAppeared)
                .opacity(isAppeared ? 1 : 0)
                .animation(.easeInOut.delay(0.1), value: isAppeared)
        })
        .onAppear {
            isAppeared = true
        }
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
