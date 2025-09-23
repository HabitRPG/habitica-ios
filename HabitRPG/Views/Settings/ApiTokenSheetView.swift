//
//  ApiTokenSheetView.swift
//  Habitica
//
//  Created by fiz on 6/5/25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct ApiTokenSheetView: View, Dismissable {
    let token: String
    var onCopy: () -> Void
    var dismisser = Dismisser()
    @Environment(\.colorScheme)
    var colorScheme

    var buttonColor: Color { Color.yellow100 }
    var buttonTextColor: Color { Color.yellow1 }

    var tokenBoxBg: Color {
        colorScheme == .dark ? Color.gray100.opacity(0.18) : Color.gray600.opacity(0.95)
    }

    var theme: Theme { ThemeService.shared.theme }

    var descriptionColor: Color {
        colorScheme == .dark ? Color.gray400 : Color.gray200
    }

    var body: some View {
            VStack(spacing: 20) {
                Text(L10n.apiTokenTitle)
                    .font(.system(size: 16))
                    .foregroundColor(descriptionColor)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(L10n.apiTokenIsPassword)
                        .font(.system(size: 16))
                        .kerning(-0.31)
                        .lineSpacing(5)
                        .foregroundColor(Color(theme.primaryTextColor))
                        .padding(.bottom, 2)
                    Text(L10n.apiTokenPasswordDescription)
                        .font(.system(size: 14))
                        .kerning(-0.08)
                        .lineSpacing(4)
                        .foregroundColor(descriptionColor)
                        .padding(.bottom, 12)
                    Text(L10n.apiTokenResetTitle)
                        .font(.system(size: 16))
                        .kerning(-0.31)
                        .lineSpacing(5)
                        .foregroundColor(Color(theme.primaryTextColor))
                        .padding(.bottom, 2)
                    Text(L10n.apiTokenResetDesc)
                        .font(.system(size: 14))
                        .kerning(-0.08)
                        .lineSpacing(4)
                        .foregroundColor(descriptionColor)
                        .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    Image(uiImage: HabiticaIcons.imageOfLocked())
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                      .frame(width: 16, height: 16)
                    Text(token)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(tokenBoxBg)
                .cornerRadius(8)

                Button(action: {
                    onCopy()
                }) {
                    Text(L10n.copyToken)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(buttonColor)
                        .foregroundColor(buttonTextColor)
                        .font(.headline)
                        .cornerRadius(8)
                }
                .frame(minHeight: 48) 
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
}



