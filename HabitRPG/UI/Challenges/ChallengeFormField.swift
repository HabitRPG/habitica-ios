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
        case .description: return .tag
        case .tag: return nil
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
    var characterLimit: Int?
    var focus: FocusState<ChallengeFormFocus?>.Binding?
    var field: ChallengeFormFocus?

    private var showsCounter: Bool {
        guard let characterLimit = characterLimit else {
            return false
        }
        return text.count >= characterLimit - 30
    }

    private var fieldIdentifier: String {
        guard let field = field else {
            return ""
        }
        switch field {
        case .name:
            return "challengeForm.name"
        case .summary:
            return "challengeForm.summary"
        case .description:
            return "challengeForm.description"
        case .tag:
            return "challengeForm.tag"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                label
                    .font(.system(size: 17, weight: .semibold))
                Spacer(minLength: 0)
                if let characterLimit = characterLimit, showsCounter {
                    characterCounter(limit: characterLimit)
                }
            }
            .padding(.horizontal, 8)
            .animation(.easeInOut(duration: 0.2), value: showsCounter)
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(ChallengeTheme.counter), axis: multiline ? .vertical : .horizontal)
                .font(.system(size: 17))
                .accessibilityIdentifier(fieldIdentifier)
                .lineLimit(multiline ? 3...8 : 1...1)
                .padding(.vertical, 17)
                .padding(.horizontal, 20)
                .frame(minHeight: multiline ? (minHeight ?? 78) : nil, alignment: .top)
                .background(ChallengeTheme.formFieldFill)
                .clipShape(RoundedRectangle(cornerRadius: ChallengeTheme.containerRadius, style: .continuous))
                .modifier(ChallengeFieldFocus(focus: focus, field: field))
                .onChange(of: text) { _, newValue in
                    guard let characterLimit = characterLimit, newValue.count > characterLimit else {
                        return
                    }
                    text = String(newValue.prefix(characterLimit))
                }
        }
        .id(field)
    }

    private func characterCounter(limit: Int) -> some View {
        let isAtLimit = text.count >= limit
        let tint = isAtLimit ? Color(themeService.theme.errorColor) : ChallengeTheme.formSectionLabel
        return Text("\(text.count) / \(limit)")
            .font(.system(size: 13, weight: .semibold))
            .monospacedDigit()
            .foregroundStyle(tint)
            .padding(.vertical, 3)
            .padding(.horizontal, 9)
            .background(isAtLimit ? Color(themeService.theme.errorColor).opacity(0.14) : ChallengeTheme.chipFill)
            .clipShape(Capsule())
            .transition(.opacity.combined(with: .scale(scale: 0.92)))
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
        return isSelected ? ChallengeTheme.selectedRowText : Color(themeService.theme.primaryTextColor)
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
                        .foregroundStyle(ChallengeTheme.selectedRowText)
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
        .background(ChallengeTheme.formFieldFill)
        .clipShape(RoundedRectangle(cornerRadius: ChallengeTheme.containerRadius, style: .continuous))
    }
}