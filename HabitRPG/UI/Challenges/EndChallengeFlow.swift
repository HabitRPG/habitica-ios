import SwiftUI
import Habitica_Models

struct EndChallengeFlow: View {
    let challenge: ChallengeProtocol
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            EndChallengeSheet(challenge: challenge, onClose: onClose)
        }
    }
}

struct EndChallengeSheet: View {
    @ObservedObject private var themeService = ThemeService.shared
    let challenge: ChallengeProtocol
    let onClose: () -> Void

    @State private var showSearch = false
    @State private var showDeleteConfirm = false
    private let socialRepository = SocialRepository()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ChallengeSheetHeader(title: L10n.endChallenge, onClose: onClose)
                    .padding(.top, 6)
                Image(uiImage: Asset._42Gems.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .padding(.top, 14)
                Text(L10n.endChallengeSelectWinnerTitle)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
                    .padding(.top, 18)
                Text(L10n.endChallengeSelectWinnerBody)
                    .font(.system(size: 15))
                    .foregroundStyle(Color(themeService.theme.secondaryTextColor))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 320)
                    .padding(.top, 8)
                ChallengePillButton(L10n.endChallengeSelectWinnerButton, fill: ChallengeTheme.purple) {
                    showSearch = true
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
                orDivider
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                Text(L10n.deleteChallengeTitle)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(ChallengeTheme.deleteRed)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                Text(L10n.deleteChallengeBody)
                    .font(.system(size: 15))
                    .foregroundStyle(Color(themeService.theme.secondaryTextColor))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 330)
                    .padding(.top, 9)
                ChallengePillButton(L10n.deleteChallengeButton, fill: ChallengeTheme.deleteRed) {
                    showDeleteConfirm = true
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
                Spacer(minLength: 24)
            }
        }
        .navigationDestination(isPresented: $showSearch) {
            AwardWinnerSearchView(challenge: challenge, onClose: onClose)
        }
        .alert(L10n.deleteChallengeTitle, isPresented: $showDeleteConfirm) {
            Button(L10n.cancel, role: .cancel) {}
            Button(L10n.deleteChallengeButton, role: .destructive) { deleteChallenge() }
        } message: {
            Text(L10n.deleteChallengeBody)
        }
        .background(Color(themeService.theme.contentBackgroundColor).ignoresSafeArea())
    }

    private var orDivider: some View {
        HStack(spacing: 14) {
            Rectangle().fill(Color(themeService.theme.offsetBackgroundColor)).frame(height: 1)
            Text(L10n.or)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(ChallengeTheme.username)
            Rectangle().fill(Color(themeService.theme.offsetBackgroundColor)).frame(height: 1)
        }
    }

    private func deleteChallenge() {
        socialRepository.deleteChallenge(challengeID: challenge.id ?? "").observeValues { _ in }
        onClose()
    }
}

struct AwardWinnerSearchView: View {
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
            VStack(spacing: 0) {
                ChallengeSheetHeader(title: L10n.awardWinner, onClose: onClose)
                    .padding(.top, 6)
                Image(uiImage: Asset._42Gems.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .padding(.top, 14)
                Text(L10n.selectWinnerFromParticipants)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                ChallengeParticipantSearch(searchText: $searchText, members: membersVM.filtered(searchText)) { member in
                    selectedMember = ChallengeMemberBox(member: member)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                Spacer(minLength: 24)
            }
        }
        .navigationDestination(item: $selectedMember) { box in
            AwardWinnerPlayerView(challenge: challenge, member: box.member, onClose: onClose)
        }
        .background(Color(themeService.theme.contentBackgroundColor).ignoresSafeArea())
    }
}

struct AwardWinnerPlayerView: View {
    @ObservedObject private var themeService = ThemeService.shared
    let challenge: ChallengeProtocol
    let member: MemberProtocol
    let onClose: () -> Void

    @StateObject private var progressVM: ChallengeMemberProgressViewModel
    @State private var showConfirm = false
    private let socialRepository = SocialRepository()

    init(challenge: ChallengeProtocol, member: MemberProtocol, onClose: @escaping () -> Void) {
        self.challenge = challenge
        self.member = member
        self.onClose = onClose
        _progressVM = StateObject(wrappedValue: ChallengeMemberProgressViewModel(challengeID: challenge.id ?? "", memberID: member.id ?? ""))
    }

    var body: some View {
        VStack(spacing: 0) {
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
                    Spacer(minLength: 90)
                }
            }
            awardBar
        }
        .background(Color(themeService.theme.contentBackgroundColor).ignoresSafeArea())
        .alert(L10n.awardWinnerConfirm, isPresented: $showConfirm) {
            Button(L10n.cancel, role: .cancel) {}
            Button(L10n.awardWinner) { awardWinner() }
        }
    }

    private var awardBar: some View {
        ChallengePillButton(fill: ChallengeTheme.purple, action: { showConfirm = true }) {
            HStack(spacing: 9) {
                Text(L10n.awardWinner)
                Image(uiImage: Asset.gem.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 18)
                Text("\(challenge.prize)")
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 22)
        .background(Color(themeService.theme.contentBackgroundColor))
    }

    private func awardWinner() {
        socialRepository.selectChallengeWinner(challengeID: challenge.id ?? "", winnerID: member.id ?? "").observeValues { _ in }
        onClose()
    }
}
