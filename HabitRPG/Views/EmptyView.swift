//
//  EmptyView.swift
//  Habitica
//
//  Created by Phillip Thelen on 12.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct NoContentView<Icon: View, Title: View, Content: View>: View {
    let icon: Icon
    let title: Title
    let content: Content
    
    var body: some View {
        VStack(spacing: 5) {
            icon.padding(.bottom, 15)
            title
                .scaledFont(size: 16, weight: .semibold)
                .foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
            content
                .scaledFont(size: 15)
                .foregroundStyle(Color(ThemeService.shared.theme.ternaryTextColor))
        }.frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }
}

extension NoContentView where Icon == EmptyView {
    init(title: Title, content: Content) {
        self.init(icon: EmptyView(), title: title, content: content)
    }
}
