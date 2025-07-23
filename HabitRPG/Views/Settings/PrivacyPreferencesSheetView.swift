//
//  PrivacyPreferencesSheetView.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.06.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct PrivacyToggleContainer: View {
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
            }
            .frame(maxWidth: .infinity)
            Toggle(isOn: $isOn) {
            }
            .tint(Color(ThemeService.shared.theme.tintColor))
            .frame(width: 46)
                .opacity(disabled ? 0.5 : 1.0)
        }
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(16)
    }
}

struct PrivacyPreferencesSheetView: View, Dismissable {
    let userRepository = UserRepository()
    
    var dismisser = Dismisser()
    @Environment(\.colorScheme)
    var colorScheme
    
    @State var analyticsConsent: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Text(L10n.yourPrivacyPreferences)
                .foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                .font(.system(size: 16, weight: .medium))
                .padding(.bottom, 18)
                .padding(.horizontal, 13)
            Text(L10n.privacyPreferencesSheetDescription)
                .foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                .font(.system(size: 16))
                .lineSpacing(3)
                .padding(.bottom, 30)
                .padding(.horizontal, 13)
            PrivacyToggleContainer(title: Text(L10n.performanceAnalytics), description: Text(L10n.performanceAnalyticsDescription), titleTextColor: Color(ThemeService.shared.theme.primaryTextColor), descriptionTextColor: Color(ThemeService.shared.theme.secondaryTextColor), backgroundColor: Color(ThemeService.shared.theme.windowBackgroundColor), isOn: $analyticsConsent)
                .onChange(of: analyticsConsent, perform: { consented in
                    userRepository.updateUser(key: "preferences.analyticsConsent", value: consented).observeCompleted {
                        
                    }
                })
                .padding(.bottom, 8)
            PrivacyToggleContainer(title: Text(L10n.strictlyNecessary), description: Text(L10n.strictlyNecessaryDescription), titleTextColor: Color(ThemeService.shared.theme.primaryTextColor), descriptionTextColor: Color(ThemeService.shared.theme.secondaryTextColor), backgroundColor: Color(ThemeService.shared.theme.windowBackgroundColor), isOn: .constant(true), disabled: true)
        }
        .padding(.top, 24)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
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
