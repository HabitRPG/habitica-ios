//
//  Separator.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models

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
                    Text(tag.text ?? "TagName")
                        .font(.body)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark").scaledFont(size: 12, weight: .bold)
                            .transition(.scale)
                    }
                }
                .foregroundStyle(isSelected ? taskColor : Color(themeService.theme.primaryTextColor))
                .contentShape(.rect)
                .frame(minHeight: 50).padding(.horizontal, 26)
                .onTapGesture {
                    UISelectionFeedbackGenerator.oneShotSelectionChanged()
                    withAnimation(.spring(duration: 0.2)) {
                        if isSelected {
                            selectedTags.removeAll { selectedTag in
                                return selectedTag.id == tag.id
                            }
                        } else {
                            selectedTags.append(tag)
                        }
                    }
                }
                if tag.id != allTags.last?.id {
                    Divider()
                }
            }
        }
    }
}
