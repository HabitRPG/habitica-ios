//
//  ChallengeFormField.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.03.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//


import SwiftUI
import Habitica_Models
import ReactiveSwift

enum ChallengeFormFocus: Hashable {
    case name
    case summary
    case description
    case tag

    var next: ChallengeFormFocus? {
        switch self {
        case .name: return .summary
        case .summary: return .description
        case .description, .tag: return nil
        }
    }
}

struct ChallengeFormField<Label: View>: View {
    @ObservedObject private var themeService = ThemeService.shared
    let label: Label
    @Binding var text: String
    let multiline: Bool
    let placeholder: String
    var minHeight: CGFloat?
    var focus: FocusState<ChallengeFormFocus?>.Binding?
    var field: ChallengeFormFocus?

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            label
                .font(.system(size: 17, weight: .semibold))
                .padding(.leading, 8)
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(ChallengeTheme.counter), axis: multiline ? .vertical : .horizontal)
                .font(.system(size: 17))
                .lineLimit(multiline ? 3...8 : 1...1)
                .padding(.vertical, 17)
                .padding(.horizontal, 20)
                .frame(minHeight: multiline ? (minHeight ?? 78) : nil, alignment: .top)
                .background(Color(themeService.theme.windowBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: ChallengeTheme.containerRadius, style: .continuous))
                .modifier(ChallengeFieldFocus(focus: focus, field: field))
        }
        .id(field)
    }
}

private struct ChallengeFieldFocus: ViewModifier {
    let focus: FocusState<ChallengeFormFocus?>.Binding?
    let field: ChallengeFormFocus?

    func body(content: Content) -> some View {
        if let focus = focus, let field = field {
            content.focused(focus, equals: field)
        } else {
            content
        }
    }
}

struct ChallengeSelectionRow: View {
    @ObservedObject private var themeService = ThemeService.shared
    let title: String
    let isSelected: Bool
    var isDisabled = false
    var showsCheckmark = false
    var showsDivider = true
    let onTap: () -> Void

    private var titleColor: Color {
        if isDisabled {
            return Color(themeService.theme.quadTextColor)
        }
        return isSelected ? ChallengeTheme.deepPurple : Color(themeService.theme.primaryTextColor)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(titleColor)
                Spacer()
                if isSelected && showsCheckmark {
                    Image(systemName: "checkmark")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(ChallengeTheme.deepPurple)
                }
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
            .contentShape(.rect)
            .onTapGesture {
                if !isDisabled {
                    onTap()
                }
            }
            if showsDivider {
                Divider().padding(.horizontal, 20)
            }
        }
    }
}

struct ChallengeSelectionList<Content: View>: View {
    @ObservedObject private var themeService = ThemeService.shared
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .background(Color(themeService.theme.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: ChallengeTheme.containerRadius, style: .continuous))
    }
}