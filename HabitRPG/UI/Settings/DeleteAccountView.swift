//
//  DeleteAccountView.swift
//  
//
//  Created by Phillip Thelen on 24.09.26.
//
import UIKit
import Eureka
import ReactiveSwift
import Habitica_Models
import SwiftUI

struct DeleteAccountView: View {
    let dismisser: () -> Void
    let onDelete: (String) -> Void
    let onForgotPassword: () -> Void
    let isSocial: Bool
    @State var text: String = ""
    
    private func isValidInput() -> Bool {
        if isSocial {
            return text == "DELETE"
        } else {
            return !text.isEmpty
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.Settings.deleteAccountConfirm).font(.headline)
                if isSocial {
                    Text(L10n.Settings.deleteAccountDescriptionSocial).font(.body).foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                } else {
                    Text(L10n.Settings.deleteAccountDescription).font(.body).foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                }
                Group {
                    if isSocial {
                        TextField(text: $text, prompt: Text("DELETE")) {
                        }
                    } else {
                        SecureField(text: $text, prompt: Text(L10n.password)) {
                        }
                    }
                }
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(16)
                .overlay(RoundedRectangle(cornerRadius: UIConstants.largeCornerRadius).stroke().foregroundStyle(Color(ThemeService.shared.theme.tableviewSeparatorColor)))
                HabiticaButtonUI(label: Text(L10n.Settings.deleteAccount), color: Color(isValidInput() ? ThemeService.shared.theme.errorColor : ThemeService.shared.theme.dimmedColor)) {
                    onDelete(text)
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
