//
//  MountRaisedSheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models

struct MountRaisedSheet: View, Dismissable {
    @ObservedObject var themeService = ThemeService.shared
    var dismisser = Dismisser()
    let mount: AnimalProtocol
    var onEquip: () -> Void = { }
    
    var body: some View {
        if mount.isValid {
            GamifiedBottomSheet(upperBackground: StableBackgroundView(),
                                upperContent: MountView(mount: mount).padding(.top, 30),
                                upperContentBottomPadding: 10,
                                title: Text(L10n.youRaisedPet(mount.text ?? ""))) {
                HabiticaButtonUI(label: Text(L10n.equip), color: Color(themeService.theme.fixedTintColor)) {
                    onEquip()
                    dismisser.dismiss()
                }
                HabiticaButtonUI(label: Text(L10n.share).foregroundStyle(Color(themeService.theme.primaryTextColor)), color: Color(themeService.theme.offsetBackgroundColor)) {
                    SharingManager.share(mount: mount, shareIdentifier: "raisedPet")
                    dismisser.dismiss()
                }
            }
        }
    }
}

#Preview {
    MountRaisedSheet(mount: PreviewMount(egg: "BearCub", potion: "Base", type: "drop", text: "Base Bear Cub"))
}
