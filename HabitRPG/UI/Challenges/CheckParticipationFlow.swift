import SwiftUI
import Habitica_Models

struct CheckParticipationView: View {
    @ObservedObject private var themeService = ThemeService.shared
    let challenge: ChallengeProtocol
    let onClose: () -> Void

    @StateObject private var membersVM: ChallengeMembersViewModel
    @State private var searchText = ""
    @State private var selectedMember: ChallengeMemberBox?

    init(challenge: ChallengeProtocol, onClose: @escaping () -> Void) {
        self.challenge = challenge
        self.onClose = onClose
        _membersVM = StateObject(wrappedValue: ChallengeMembersViewModel(challengeID: challenge.id ?? ""))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    ChallengeCircleButton(systemName: "xmark", diameter: 36, action: onClose)
                }
                .padding(.top, 6)
                Text(L10n.checkOnParticipation)
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
                    .padding(.top, 8)
                Text(L10n.checkParticipationBody)
                    .font(.system(size: 16))
                    .foregroundStyle(Color(themeService.theme.secondaryTextColor))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 8)
                Text(L10n.viewProgressOf)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
                    .padding(.top, 24)
                    .padding(.bottom, 10)
                ChallengeParticipantSearch(searchText: $searchText, members: membersVM.filtered(searchText)) { member in
                    selectedMember = ChallengeMemberBox(member: member)
                }
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 22)
        }
        .background(Color(themeService.theme.contentBackgroundColor).ignoresSafeArea())
        .sheet(item: $selectedMember) { box in
            ParticipantProgressSheet(challenge: challenge, member: box.member, onClose: { selectedMember = nil })
                .presentationDetents([.large])
                .presentationCornerRadius(30)
                .presentationDragIndicator(.visible)
        }
    }
}

struct ParticipantProgressSheet: View {
    @ObservedObject private var themeService = ThemeService.shared
    let challenge: ChallengeProtocol
    let member: MemberProtocol
    let onClose: () -> Void

    @StateObject private var progressVM: ChallengeMemberProgressViewModel

    init(challenge: ChallengeProtocol, member: MemberProtocol, onClose: @escaping () -> Void) {
        self.challenge = challenge
        self.member = member
        self.onClose = onClose
        _progressVM = StateObject(wrappedValue: ChallengeMemberProgressViewModel(challengeID: challenge.id ?? "", memberID: member.id ?? ""))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ChallengeSheetHeader(title: member.profile?.name ?? "", subtitle: "@\(member.username ?? "")", onClose: onClose)
                    .padding(.top, 6)
                AvatarViewUI(avatar: AvatarViewModel(avatar: member))
                    .frame(width: 142, height: 142)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .padding(.top, 10)
                ChallengeParticipantTaskList(memberName: member.profile?.name ?? "", tasks: progressVM.tasks)
                    .padding(.horizontal, 18)
                Spacer(minLength: 24)
            }
        }
        .background(Color(themeService.theme.contentBackgroundColor).ignoresSafeArea())
    }
}
