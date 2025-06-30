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
    let onCopy: () -> Void
    var dismisser = Dismisser()
    @Environment(\.colorScheme) var colorScheme

    var yellow: Color { Color.yellow100 }

    var tokenBoxBg: Color {
        colorScheme == .dark ? Color.gray100.opacity(0.18) : Color.gray600.opacity(0.95)
    }

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.gray300.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 24)
            
            VStack(spacing: 20) {
                Text(L10n.apiTokenTitle)
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(L10n.apiTokenIsPassword)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text(L10n.apiTokenPasswordDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(L10n.apiTokenResetTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.top, 4)
                    Text(L10n.apiTokenResetDesc)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
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
                    dismisser.dismiss?()
                }) {
                    Text(L10n.copyToken)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(yellow)
                        .foregroundColor(.black)
                        .font(.headline)
                        .cornerRadius(8)
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}



