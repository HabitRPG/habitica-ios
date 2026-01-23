//
//  LevelupSheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 19.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models

class LevelupViewModel: ViewModel {
    private let userRepository = UserRepository()
    
    @Published var user: UserProtocol?
    
    var level: Int {
        return user?.stats?.level ?? 0
    }
    
    var canSelectClass: Bool {
        return user?.flags?.classSelected == false && user?.preferences?.disableClasses == false && (user?.stats?.level ?? 0) >= 10
    }
    
    override init() {
        super.init()
        disposable.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
        }).start())
    }
}

struct LevelupSheet: View {
    @ObservedObject var themeService = ThemeService.shared
    @Environment(\.presentationManager)
    var presentationManager
    
    @ObservedObject var viewModel: LevelupViewModel = LevelupViewModel()
    
    var body: some View {
        GamifiedBottomSheet(upperContent: VStack(spacing: 16) {
            HStack(spacing: 24) {
                Image(Asset.levelupstarsLeft.name)
                if viewModel.canSelectClass {
                    Image(Asset.classUnlockIcon.name)
                } else {
                    ZStack {
                        Image(Asset.avatarBorder.name)
                        if let user = viewModel.user {
                            AvatarViewUI(avatar: AvatarViewModel(avatar: user))
                                .frame(width: 140, height: 147)
                        }
                    }
                }
                Image(Asset.levelupstarsRight.name)
            }
            Text(L10n.levelupTitle(viewModel.level))
                .scaledFont(size: 22, weight: .bold)
                .foregroundStyle(.white)
                .padding(.horizontal, 50)
        }.padding(.top, 50), title: Group {
            if viewModel.canSelectClass {
                Text(L10n.classSystemUnlocked)
            }
        }, description: VStack(spacing: 20) {
            if viewModel.canSelectClass {
                Text(L10n.classSystemUnlockedDescription)
                Text(L10n.classSystemEnableInstructions).foregroundStyle(Color(themeService.theme.ternaryTextColor)).scaledFont(size: 15, weight: .semibold)
            } else {
                Text(L10n.levelupDescription)
            }
        }) {
            if viewModel.canSelectClass {
                HabiticaButtonUI(label: Text(L10n.Titles.selectClass), color: Color(themeService.theme.fixedTintColor)) {
                    if let user = viewModel.user {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            UserManager.shared.showClassSelection(user: user)
                        }
                    }
                    presentationManager.dismiss()
                }
                HabiticaButtonUI(label: Text(L10n.notNow).foregroundStyle(Color(themeService.theme.primaryTextColor)),
                                 color: Color(themeService.theme.offsetBackgroundColor)) {
                    presentationManager.dismiss()
                }
            } else {
                HabiticaButtonUI(label: Text(L10n.onwards), color: Color(themeService.theme.fixedTintColor)) {
                    presentationManager.dismiss()
                }
                HabiticaButtonUI(label: Text(L10n.share).foregroundStyle(Color(themeService.theme.primaryTextColor)),
                                 color: Color(themeService.theme.offsetBackgroundColor)) {
                    var items: [Any] = [
                        L10n.levelupShare(viewModel.user?.stats?.level ?? 0)
                    ]
                    if let user = viewModel.user {
                        items.append(AvatarViewUI(avatar: AvatarViewModel(avatar: user))
                            .frame(width: 140, height: 147)
                            .snapshot())
                    }
                    SharingManager.share(identifier: "levelup", items: items, presentingViewController: nil, sourceView: nil)
                    presentationManager.dismiss()
                }
            }
        }
    }
}
