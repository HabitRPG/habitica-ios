//
//  LookingForPartyViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 14.06.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import Foundation
import SwiftUI
import Habitica_Models

class LookingForPartyViewModel: ObservableObject {
    let socialRepository = SocialRepository()
    
    @Published var hasLoadedInitialData = false
    @Published var members = [MemberProtocol]()
    @Published var invitedMembers = [String]()
    @Published var inviteStates = [String: LoadingButtonState]()
    
    init() {
        Task.detached {
            await self.refresh()
        }
    }
    
    func refresh() async {
        let result = socialRepository.retrieveLookingForParty().producer.first()
        switch result {
        case .success(let members):
            await MainActor.run(body: {
                self.members = members ?? []
                self.hasLoadedInitialData = true
            })

        default:
            await MainActor.run(body: {
                self.members = []
                self.hasLoadedInitialData = true
            })
        }
    }
    
    func cancelInvite(uuid: String) {
        inviteStates[uuid] = .loading
        socialRepository.removeMember(groupID: "party", userID: uuid).on(completed: {
            if self.inviteStates[uuid] == .success {
                return
            }
            self.inviteStates[uuid] = .failed
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.inviteStates[uuid] = .content
            }
        }).observeValues { result in
            if result != nil {
                self.inviteStates[uuid] = .success
                self.invitedMembers.append(uuid)
            } else {
                self.inviteStates[uuid] = .failed
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.inviteStates[uuid] = .content
            }
        }
    }
    
    func invite(uuid: String) {
        inviteStates[uuid] = .loading
        socialRepository.invite(toGroup: "party", members: ["uuids": [uuid]]).observeValues { result in
            if result != nil {
                self.inviteStates[uuid] = .success
                if let index = self.invitedMembers.firstIndex(of: uuid) {
                    self.invitedMembers.remove(at: index)
                }
            } else {
                self.inviteStates[uuid] = .failed
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.inviteStates[uuid] = .content
            }
        }
    }
}

struct ClassLabel: View {
    let className: String
    let selectedClass: Bool
    
    private func classImage() -> UIImage? {
        switch className {
        case "warrior":
            return HabiticaIcons.imageOfWarriorLightBg
        case "wizard":
            return HabiticaIcons.imageOfMageLightBg
        case "healer":
            return HabiticaIcons.imageOfHealerLightBg
        case "rogue":
            return HabiticaIcons.imageOfRogueLightBg
        default:
            return nil
        }
    }
    
    private func classColor() -> UIColor? {
        switch className {
        case "warrior":
            return UIColor.maroon10
        case "wizard":
            return UIColor.blue10
        case "healer":
            return UIColor.yellow10
        case "rogue":
            return UIColor.purple300
        default:
            return nil
        }
    }
    
    var body: some View {
        if selectedClass {
            HStack {
                if let classImage = classImage() {
                    Image(uiImage: classImage)
                }
                Text(className).foregroundColor(Color(classColor() ?? ThemeService.shared.theme.primaryTextColor)).font(.subheadline)
            }
        }
        
    }
}

struct PartyInviteView: View {
    let member: MemberProtocol
    let inviteButtonState: LoadingButtonState
    let isInvited: Bool
    let onInvite: () -> Void
    
    var body: some View {
        VStack( spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                AvatarViewUI(avatar: AvatarViewModel(avatar: member)).frame(width: 97, height: 99).padding(.top, 4)
                VStack(alignment: .leading, spacing: 1) {
                    Text(member.profile?.name ?? "")
                        .font(.headline)
                    Text("@\(member.username ?? "")")
                        .font(.system(size: 14))
                        .foregroundColor(Color(ThemeService.shared.theme.secondaryTextColor))
                    Rectangle().fill()
                        .foregroundColor(Color(ThemeService.shared.theme.separatorColor))
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .padding(.vertical, 2)
                    HStack {
                        Text(L10n.levelNumber(member.stats?.level ?? 0))
                        Spacer()
                        ClassLabel(className: member.stats?.habitClass ?? "warrior", selectedClass: member.flags?.classSelected ?? false)
                    }
                    Text("\(member.loginIncentives) Check-ins")
                    if let language = Locale.current.localizedString(forLanguageCode: member.preferences?.language ?? "en") {
                        Text(language)
                    }
                }
                .foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
                .font(.system(size: 14, weight: .semibold))
            }
            if let id = member.id {
                LoadingButton(state: .constant(inviteButtonState),
                              type: isInvited ? .destructive : .normal,
                              onTap: {
                    onInvite()
                },
                              content: Text(isInvited ? L10n.Groups.cancelInvite : L10n.Groups.sendInvite),
                              successContent: Text(isInvited ? L10n.Groups.invited : L10n.cancelled))
            }
        }
    }
}

struct LookingForPartyView: View {
    @ObservedObject var viewModel: LookingForPartyViewModel
    
    private var content: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                VStack(alignment: .center) {
                    Text("Find more members").font(.headline)
                    if !viewModel.hasLoadedInitialData || !viewModel.members.isEmpty {
                        Text(L10n.Groups.Lfp.subtitle).font(.body)
                    } else {
                        Text(L10n.Groups.Lfp.subtitleEmpty).font(.body)
                    }
                }.frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 6)
                if !viewModel.hasLoadedInitialData {
                    ProgressView().progressViewStyle(.circular)
                } else {
                    ForEach(viewModel.members, id: \.id) { member in
                        if let id = member.id {
                            PartyInviteView(member: member, inviteButtonState: viewModel.inviteStates[id] ?? .content, isInvited: viewModel.invitedMembers.contains(id)) {
                                if viewModel.invitedMembers.contains(id) {
                                    viewModel.cancelInvite(uuid: id)
                                } else {
                                    viewModel.invite(uuid: id)
                                }
                            }
                            .padding(.top, 8)
                            .padding(.horizontal, 12)
                            .padding(.bottom, 12)
                            .background(Color(ThemeService.shared.theme.windowBackgroundColor))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
            .padding(14)
        }
    }
    
    var body: some View {
        if #available(iOS 15.0, *), viewModel.hasLoadedInitialData {
            content.refreshable {
                await viewModel.refresh()
            }
        } else {
            content
        }
    }
}

class LookingForPartyViewController: UIHostingController<LookingForPartyView> {
    let viewModel = LookingForPartyViewModel()
    
    init() {
        super.init(rootView: LookingForPartyView(viewModel: viewModel))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: LookingForPartyView(viewModel: viewModel))
    }
}
