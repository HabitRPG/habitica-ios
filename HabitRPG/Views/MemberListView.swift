//
//  MemberListView.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import PinLayout
import SwiftUI

struct MemberListItem: View {
    
    let member: MemberProtocol
    let onTap: (MemberProtocol) -> Void
    let onMoreTap: (MemberProtocol) -> Void
    
    var body: some View {
        HStack {
            if let stats = member.stats {
                AvatarViewUI(avatar: AvatarViewModel(avatar: member)).frame(width: 97, height: 99)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(member.profile?.name ?? "").font(.headline)
                        Spacer()
                        Button {
                            onMoreTap(member)
                        } label: {
                            Image(uiImage: Asset.moreInteractionsIcon.image)
                        }

                    }
                    HStack {
                        Text("@\(member.username ?? "") · Lvl \(member.stats?.level ?? 0)").font(.subheadline).foregroundColor(.secondary)
                        Spacer()
                        if member.stats?.buffs?.isBuffed == true {
                            Image(uiImage: HabiticaIcons.imageOfBuffIcon)
                        }
                    }
                    HStack(spacing: 12) {
                        VStack {
                            ProgressBarUI(value: stats.health / stats.maxHealth).foregroundColor(Color(UIColor.red100)).frame(height: 8)
                            ProgressBarUI(value: stats.experience / stats.toNextLevel).foregroundColor(Color(UIColor.yellow50)).frame(height: 8)
                            ProgressBarUI(value: stats.mana / stats.maxMana).foregroundColor(Color(UIColor.blue100)).frame(height: 8)
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            Text("\(Int(stats.health)) / \(Int(stats.maxHealth))").font(.system(size: 12)).foregroundColor(Color(ThemeService.shared.theme.ternaryTextColor)).frame(height: 16)
                            Text("\(Int(stats.experience)) / \(Int(stats.toNextLevel))").font(.system(size: 12)).foregroundColor(Color(ThemeService.shared.theme.ternaryTextColor)).frame(height: 16)
                            Text("\(Int(stats.mana)) / \(Int(stats.maxMana))").font(.system(size: 12)).foregroundColor(Color(ThemeService.shared.theme.ternaryTextColor)).frame(height: 16)
                        }
                    }
                }.frame(width: .infinity)
            }
        }.padding(.vertical, 8).background(Color(ThemeService.shared.theme.contentBackgroundColor)).onTapGesture {
            onTap(member)
        }
    }
}

struct MemberList: View {
    
    let members: [MemberProtocol]
    let onTap: (MemberProtocol) -> Void
    let onMoreTap: (MemberProtocol) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(members, id: \.id) { member in
                MemberListItem(member: member, onTap: onTap, onMoreTap: onMoreTap)
            }
        }
    }
}
