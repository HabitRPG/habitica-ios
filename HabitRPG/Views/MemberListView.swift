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
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if let stats = member.stats {
                AvatarViewUI(avatar: AvatarViewModel(avatar: member)).frame(width: 97, height: 99)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        UsernameLabelUI(name: member.profile?.name ?? "", level: member.contributor?.level ?? 0)
                            .font(.headline)
                        Spacer()
                        if !isCurrentUser {
                            Button {
                                onMoreTap(member)
                            } label: {
                                Image(uiImage: Asset.moreInteractionsIcon.image)
                            }.overlay {
                                Rectangle().foregroundColor(.clear)
                                    .frame(width: 40, height: 40)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        onMoreTap(member)
                                    }
                            }
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
                            Text("\(stats.health, specifier: "%.0f") / \(stats.maxHealth, specifier: "%.0f")")
                                .frame(height: 16)
                            Text("\(stats.experience, specifier: "%.0f") / \(stats.toNextLevel, specifier: "%.0f")")
                                .frame(height: 16)
                            Text("\(stats.mana, specifier: "%.0f") / \(stats.maxMana, specifier: "%.0f")")
                                .frame(height: 16)
                        }
                        .font(.system(size: 12))
                        .foregroundColor(Color(ThemeService.shared.theme.ternaryTextColor))
                    }
                }.frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(Color(ThemeService.shared.theme.windowBackgroundColor))
        .cornerRadius(12)
        .onTapGesture {
            onTap(member)
        }
    }
}

struct MemberList: View {
    let members: [MemberProtocol]
    @State var invites: [MemberProtocol]
    let isLeader: Bool
    let onTap: (MemberProtocol) -> Void
    let onMoreTap: (MemberProtocol) -> Void
    
    init(members: [MemberProtocol], invites: [MemberProtocol]?, isLeader: Bool, onTap: @escaping (MemberProtocol) -> Void, onMoreTap: @escaping (MemberProtocol) -> Void) {
        self.members = members
        _invites = State(initialValue: invites ?? [])
        self.isLeader = isLeader
        self.onTap = onTap
        self.onMoreTap = onMoreTap
    }
    
    let socialRepository = SocialRepository()
    
    @State var inviteStates = [String: LoadingButtonState]()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(members, id: \.id) { member in
                MemberListItem(member: member, onTap: onTap, onMoreTap: onMoreTap, isCurrentUser: member.id == socialRepository.currentUserId)
            }
            ForEach(invites, id: \.id) { invite in
                if let id = invite.id {
                    PartyInviteView(member: invite, inviteButtonState: inviteStates[id] ?? .content, isInvited: inviteStates[id] != .success, onInvite: {
                        inviteStates[id] = .loading
                        socialRepository.removeMember(groupID: "party", userID: id).observeCompleted {
                            ToastManager.show(text: L10n.Groups.removed(invite.profile?.name ?? "player"), color: .red)
                            inviteStates[id] = .failed
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                invites.removeAll { check in
                                    return check.id == invite.id
                                }
                            }
                        }
                    }, canInvite: isLeader, isPending: true)
                    .padding(16)
                    .background(Color(ThemeService.shared.theme.windowBackgroundColor))
                    .cornerRadius(12)
                }
            }
        }
    }
}
