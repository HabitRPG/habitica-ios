//
//  ResetAccountView.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.09.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//
import UIKit
import Eureka
import ReactiveSwift
import Habitica_Models
import SwiftUI

struct ResetAccountView: View {
    let dismisser: () -> Void
    let onReset: (String) -> Void
    let onForgotPassword: () -> Void
    let isSocial: Bool
    @State var text: String = ""
    
    private func isValidInput() -> Bool {
        if isSocial {
            return text == "RESET"
        } else {
            return !text.isEmpty
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.Settings.resetAccountConfirm).font(.headline)
                if isSocial {
                    Text(L10n.Settings.resetAccountDescriptionSocial).font(.body).foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                } else {
                    Text(L10n.Settings.resetAccountDescription).font(.body).foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                }
                Group {
                    if isSocial {
                        TextField(text: $text, prompt: Text("RESET")) {
                        }
                    } else {
                        SecureField(text: $text, prompt: Text(L10n.password)) {
                        }
                    }
                }
                .padding(16)
                .overlay(RoundedRectangle(cornerRadius: UIConstants.largeCornerRadius).stroke().foregroundStyle(Color(ThemeService.shared.theme.tableviewSeparatorColor)))
                HabiticaButtonUI(label: Text(L10n.Settings.resetAccount), color: Color(isValidInput() ? ThemeService.shared.theme.errorColor : ThemeService.shared.theme.dimmedColor)) {
                    onReset(text)
                }
                if !isSocial {
                    Text(L10n.Login.forgotPassword)
                        .foregroundStyle(Color(ThemeService.shared.theme.tintColor))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture {
                            onForgotPassword()
                        }
                        .padding(16)
                }
            }.padding(16)
        }
    }
}
