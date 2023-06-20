//
//  LoadingButton.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.05.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import SwiftUI

enum LoadingButtonState: Hashable {
    case content
    case disabled
    case loading
    case failed
    case success
}

enum LoadingButtonType {
    case normal
    case destructive
}

struct LoadingButton<Content: View, SuccessContent: View>: View {
    @Binding var state: LoadingButtonState
    var type: LoadingButtonType = .normal
    let onTap: () -> Void
    let content: Content
    var successContent: SuccessContent
    var contentPadding: EdgeInsets = .zero
    
    private func getBackgroundColor() -> UIColor {
        let theme = ThemeService.shared.theme
        switch state {
        case .content, .loading:
            if type == .destructive {
                return theme.errorColor
            } else {
                return theme.backgroundTintColor
            }
        case .disabled:
            return theme.dimmedColor
        case .failed:
            return theme.errorColor
        case .success:
            return theme.successColor
        }
    }
    
    @ViewBuilder
    private func getContent() -> some View {
        if state == .loading {
            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.white)).padding(4)
        } else if state == .failed {
            Text(L10n.failed)
        } else if state == .success {
            if successContent is EmptyView {
                content
            } else {
                successContent
            }
        } else {
            content
        }
    }
    
    var body: some View {
        HabiticaButtonUI(label: getContent(), color: Color(getBackgroundColor()), size: .compact, type: (state == .failed || state == .success) ? .bordered : .solid, onTap: onTap)
    }
}

extension LoadingButton where SuccessContent == EmptyView {
    init(state: Binding<LoadingButtonState>, onTap: @escaping () -> Void, content: Content) {
        self.init(state: state, onTap: onTap, content: content, successContent: EmptyView())
    }
}

struct LoadingButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 8) {
            LoadingButton(state: .constant(.content), onTap: {}, content: Text("Content"))
            LoadingButton(state: .constant(.disabled), onTap: {}, content: Text("Disabled"))
            LoadingButton(state: .constant(.loading), onTap: {}, content: Text("Loading"))
            LoadingButton(state: .constant(.failed), onTap: {}, content: Text("Failed"))
            LoadingButton(state: .constant(.success), onTap: {}, content: Text("Success"))
            LoadingButton(state: .constant(.success), onTap: {}, content: Text("User was invited"))
        }
        .padding(8)
        .previewLayout(.sizeThatFits)
    }
}
