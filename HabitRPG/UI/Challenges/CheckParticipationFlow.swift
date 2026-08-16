import SwiftUI
import Habitica_Models

struct CheckParticipationView: View {
    @ObservedObject private var themeService = ThemeService.shared
    let challenge: ChallengeProtocol
    let onClose: () -> Void
    let onFinished: () -> Void

    @StateObject private var membersVM: ChallengeMembersViewModel
    @State private var searchText = ""
    @State private var selectedMember: ChallengeMemberBox?

    init(challenge: ChallengeProtocol, onClose: @escaping () -> Void, onFinished: @escaping () -> Void) {
        self.challenge = challenge
        self.onClose = onClose
        self.onFinished = onFinished
        _membersVM = StateObject(wrappedValue: ChallengeMembersViewModel(challengeID: challenge.id ?? ""))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    ChallengeCircleButton(systemName: "xmark", action: onClose)
                }
                .padding(.top, 20)
                Text(L10n.checkOnParticipation)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
                    .padding(.top, 8)
                    .padding(.horizontal, 8)
                Text(L10n.checkParticipationBody)
                    .font(.system(size: 17))
                    .foregroundStyle(ChallengeTheme.handle)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 8)
                    .padding(.horizontal, 8)
                Text(L10n.viewProgressOf)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
                    .padding(.top, 24)
                    .padding(.bottom, 10)
                    .padding(.horizontal, 8)
                ChallengeParticipantSearch(searchText: $searchText, members: membersVM.filtered(searchText)) { member in
                    selectedMember = ChallengeMemberBox(member: member)
                }
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 18)
        }
        .background(Color(themeService.theme.contentBackgroundColor).ignoresSafeArea())
        .sheet(item: $selectedMember) { box in
            ParticipantProgressSheet(challenge: challenge, member: box.member, onClose: { selectedMember = nil }, onAwarded: onFinished)
        }
    }
}

struct ParticipantProgressSheet: View {
    @ObservedObject private var themeService = ThemeService.shared
    let challenge: ChallengeProtocol
    let member: MemberProtocol
    let onClose: () -> Void
    let onAwarded: () -> Void

    @StateObject private var progressVM: ChallengeMemberProgressViewModel

    init(challenge: ChallengeProtocol, member: MemberProtocol, onClose: @escaping () -> Void, onAwarded: @escaping () -> Void) {
        self.challenge = challenge
        self.member = member
        self.onClose = onClose
        self.onAwarded = onAwarded
        _progressVM = StateObject(wrappedValue: ChallengeMemberProgressViewModel(challengeID: challenge.id ?? "", memberID: member.id ?? ""))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ChallengeSheetHeader(title: member.profile?.name ?? "", subtitle: "@\(member.username ?? "")", onClose: onClose)
                        .padding(.top, 32)
                    AvatarViewUI(avatar: AvatarViewModel(avatar: member))
                        .frame(width: 142, height: 142)
                        .clipShape(RoundedRectangle(cornerRadius: ChallengeTheme.containerRadius, style: .continuous))
                        .padding(.top, 22)
                        .padding(.bottom, 10)
                    ChallengeParticipantTaskList(memberName: member.profile?.name ?? "", tasks: progressVM.tasks)
                    Spacer(minLength: 90)
                }
            }
            ChallengeAwardWinnerBar(challenge: challenge, member: member, onAwarded: onAwarded)
        }
        .background(Color(themeService.theme.contentBackgroundColor).ignoresSafeArea())
    }
}
