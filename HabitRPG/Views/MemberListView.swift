//
//  MemberListView.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
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
                }.frame(maxWidth: .infinity)
            }
        }.padding(.vertical, 8).background(Color(ThemeService.shared.theme.windowBackgroundColor)).onTapGesture {
            onTap(member)
        }
    }
}

struct MemberList: View {
    let members: [MemberProtocol]
    @State var invites: [MemberProtocol]
    let onTap: (MemberProtocol) -> Void
    let onMoreTap: (MemberProtocol) -> Void
    
    init(members: [MemberProtocol], invites: [MemberProtocol]?, onTap: @escaping (MemberProtocol) -> Void, onMoreTap: @escaping (MemberProtocol) -> Void) {
        self.members = members
        _invites = State(initialValue: invites ?? [])
        self.onTap = onTap
        self.onMoreTap = onMoreTap
    }
    
    let socialRepository = SocialRepository()
    
    @State var inviteStates = [String: LoadingButtonState]()
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(members, id: \.id) { member in
                MemberListItem(member: member, onTap: onTap, onMoreTap: onMoreTap)
            }
            ForEach(invites, id: \.id) { invite in
                if let id = invite.id {
                    PartyInviteView(member: invite, inviteButtonState: inviteStates[id] ?? .content, isInvited: inviteStates[id] != .success) {
                        inviteStates[id] = .loading
                        socialRepository.removeMember(groupID: "party", userID: id).observeCompleted {
                            inviteStates[id] = .success
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                invites.removeAll { check in
                                    return check.id == invite.id
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .cornerRadius(8)
                }
            }
        }
    }
}
