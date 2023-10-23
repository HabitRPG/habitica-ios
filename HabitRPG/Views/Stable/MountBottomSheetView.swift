//
//  MountBottomSheetView.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.09.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models
import Kingfisher

struct MountBottomSheetView: View, Dismissable {
    var dismisser: Dismisser = Dismisser()

    let mount: MountProtocol
    let owned: Bool
    let isCurrentMount: Bool
    let onEquip: () -> Void
    
    var body: some View {
        let theme = ThemeService.shared.theme
        BottomSheetView(dismisser: dismisser, title: Text(mount.text ?? ""), content: VStack(spacing: 16) {
            StableBackgroundView(content: ZStack {
                KFImage(ImageManager.buildImageUrl(name: "Mount_Body_\(mount.key ?? "")")).frame(width: 72, height: 72)
                KFImage(ImageManager.buildImageUrl(name: "Mount_Head_\(mount.key ?? "")")).frame(width: 72, height: 72)
            }.frame(width: 72, height: 72)
                .padding(.top, 30), animateFlying: false)
                .clipShape(.rect(cornerRadius: 12))
            HabiticaButtonUI(label: Text(L10n.share), color: Color(theme.tintColor)) {
                dismisser.dismiss?()
            }
            if owned {
                HabiticaButtonUI(label: Text(isCurrentMount ? L10n.unequip : L10n.equip), color: Color(theme.tintColor)) {
                    onEquip()
                    dismisser.dismiss?()
                }
            }
        }
        )
    }
}

#Preview {
    MountBottomSheetView(mount: PreviewMount(egg: "BearCub", potion: "Base", type: "drop", text: "Base Bear Cub"), owned: true, isCurrentMount: false, onEquip: {})
        .previewLayout(.fixed(width: 400, height: 500))
}

private class PreviewMount: MountProtocol {
    init(egg: String, potion: String, type: String? = nil, text: String? = nil) {
        self.key = "\(egg)-\(potion)"
        self.egg = egg
        self.potion = potion
        self.type = type
        self.text = text
    }
    
    var key: String?
    var egg: String?
    var potion: String?
    var type: String?
    var text: String?
    var isValid: Bool = true
    var isManaged: Bool = true
    
}
