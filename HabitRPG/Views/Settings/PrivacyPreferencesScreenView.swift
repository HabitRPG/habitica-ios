//
//  PrivacyPreferencesSheetView 2.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.07.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI

struct PrivacyPreferencesScreenView: View, Dismissable {
    let userRepository = UserRepository()
    
    var dismisser = Dismisser()
    @Environment(\.colorScheme)
    var colorScheme
    
    @State var analyticsConsent: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(L10n.yourPrivacyPreferences)
                    .foregroundStyle(.white)
                    .scaledFont(size: 30, weight: .bold)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 13)
                Text(L10n.privacyPreferencesFullDescription)
                    .foregroundStyle(.white)
                    .scaledFont(size: 16)
                    .lineSpacing(4)
                    .padding(.bottom, 16)
                    .padding(.horizontal, 13)
                PrivacyToggleContainer(title: Text(L10n.performanceAnalytics),
                                       description: Text(L10n.performanceAnalyticsDescription),
                                       titleTextColor: .white,
                                       descriptionTextColor: .gray500,
                                       backgroundColor: .purple50,
                                       isOn: $analyticsConsent)
                .padding(.bottom, 8)
                PrivacyToggleContainer(title: Text(L10n.strictlyNecessary),
                                       description: Text(L10n.strictlyNecessaryDescription),
                                       titleTextColor: .white,
                                       descriptionTextColor: .gray500,
                                       backgroundColor: .purple50,
                                       isOn: .constant(true),
                                       disabled: true)
                Button {
                    userRepository.updateUser(key: "preferences.analyticsConsent", value: analyticsConsent).observeCompleted {
                        dismisser.dismiss()
                    }
                } label: {
                    Text(L10n.savePreferences)
                        .scaledFont(size: 16, weight: .bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .height(60)
                .background(.purple400)
                .cornerRadius(16)
                .padding(.top, 13)
                Button {
                    analyticsConsent = true
                    userRepository.updateUser(key: "preferences.analyticsConsent", value: analyticsConsent).observeCompleted {
                        dismisser.dismiss()
                    }
                } label: {
                    Text(L10n.acceptAll)
                        .scaledFont(size: 16, weight: .bold)
                        .foregroundColor(.gray50)
                        .frame(maxWidth: .infinity)
                }
                .height(60)
                .background(.white)
                .cornerRadius(16)
                .padding(.top, 8)
                if let url = URL(string: "https://habitica.com/static/privacy") {
                    Link("Habitica's Privacy Policy", destination: url)
                        .scaledFont(size: 16, weight: .bold)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.purple600)
                        .height(60)
                        .padding(.top, 12)
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 12)
            .onAppear {
                userRepository.getUser().on(value: { user in
                    analyticsConsent = user.preferences?.analyticsConsent ?? false
                }).start()
            }
        }
        .background(Color(.purple300).ignoresSafeArea())
    }
}

struct PrivacyPreferencesSheetViewPreview: PreviewProvider {
    static var previews: some View {
        PrivacyPreferencesScreenView()
    }
}
