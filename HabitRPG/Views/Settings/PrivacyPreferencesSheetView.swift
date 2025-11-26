//
//  PrivacyPreferencesSheetView.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.06.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct PrivacyToggleContainer: View {
    @ObservedObject var themeService = ThemeService.shared
    let title: Text
    let description: Text
    let titleTextColor: Color
    let descriptionTextColor: Color
    let backgroundColor: Color
    @Binding var isOn: Bool
    var disabled: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                title
                    .foregroundStyle(titleTextColor)
                    .font(.system(size: 18))
                description
                    .foregroundStyle(descriptionTextColor)
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            Toggle(isOn: $isOn) {
            }
            .tint(Color(themeService.theme.fixedTintColor))
            .frame(width: 64)
                .opacity(disabled ? 0.5 : 1.0)
        }
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(UIConstants.largeCornerRadius)
    }
}

struct PrivacyPreferencesSheetView: View, Dismissable {
    @ObservedObject var themeService = ThemeService.shared
    let userRepository = UserRepository()
    
    var dismisser = Dismisser()
    @Environment(\.colorScheme)
    var colorScheme
    
    @State var analyticsConsent: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Text(L10n.yourPrivacyPreferences)
                .foregroundStyle(Color(themeService.theme.primaryTextColor))
                .scaledFont(size: 16, weight: .medium)
                .padding(.bottom, 18)
                .padding(.horizontal, 13)
            Text((try? AttributedString(markdown: L10n.privacyPreferencesSheetDescription,
                                        options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? AttributedString(L10n.privacyPreferencesSheetDescription))
                .scaledFont(size: 14)
                .foregroundStyle(Color(themeService.theme.primaryTextColor))
                .lineSpacing(3)
                .padding(.bottom, 30)
                .padding(.horizontal, 13)
            PrivacyToggleContainer(title: Text(L10n.performanceAnalytics),
                                   description: Text(L10n.performanceAnalyticsDescription),
                                   titleTextColor: Color(themeService.theme.primaryTextColor),
                                   descriptionTextColor: Color(themeService.theme.secondaryTextColor),
                                   backgroundColor: Color(themeService.theme.windowBackgroundColor),
                                   isOn: $analyticsConsent)
                .onChange(of: analyticsConsent, perform: { consented in
                    userRepository.updateUser(key: "preferences.analyticsConsent", value: consented).observeCompleted {
                        
                    }
                })
                .padding(.bottom, 8)
            PrivacyToggleContainer(title: Text(L10n.strictlyNecessary),
                                   description: Text(L10n.strictlyNecessaryDescription),
                                   titleTextColor: Color(themeService.theme.primaryTextColor),
                                   descriptionTextColor: Color(themeService.theme.secondaryTextColor),
                                   backgroundColor: Color(themeService.theme.windowBackgroundColor),
                                   isOn: .constant(true),
                                   disabled: true)
        }
        .padding(.top, 24)
        .padding(.horizontal, 12)
        .onAppear {
            userRepository.getUser().on(value: { user in
                analyticsConsent = user.preferences?.analyticsConsent ?? false
            }).start()
        }
    }
}

struct PrivacyPreferencesShetViewPreview: PreviewProvider {
    static var previews: some View {
        PrivacyPreferencesSheetView()
    }
}
