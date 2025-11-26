//
//  Separator.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models

struct Separator: View {
    var padding: CGFloat = 14
    
    var body: some View {
        Rectangle().fill(Color(ThemeService.shared.theme.separatorColor)).frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1).padding(.horizontal, padding)
    }
}

struct TagList: View {
    @ObservedObject var themeService = ThemeService.shared
    @Binding var selectedTags: [TagProtocol]
    var allTags: [TagProtocol]
    var taskColor: Color
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(allTags, id: \.id) { tag in
                let isSelected = selectedTags.contains { selectedTag in
                    return selectedTag.id == tag.id
                }
                HStack {
                    Text(tag.text ?? "TagName").font(.body).foregroundStyle(isSelected ? Color.accentColor : Color(themeService.theme.primaryTextColor))
                    Spacer()
                    if isSelected {
                        Image(Asset.checkmarkSmall.name).foregroundStyle(.tint)
                    }
                }
                .background(Color(themeService.theme.windowBackgroundColor).cornerRadius(UIConstants.largeCornerRadius))
                .frame(height: 50).padding(.horizontal, 26)
                .onTapGesture {
                    UISelectionFeedbackGenerator.oneShotSelectionChanged()
                    if isSelected {
                        selectedTags.removeAll { selectedTag in
                            return selectedTag.id == tag.id
                        }
                    } else {
                        selectedTags.append(tag)
                    }
                }
                if tag.id != allTags.last?.id {
                    Separator()
                }
            }
        }
    }
}
