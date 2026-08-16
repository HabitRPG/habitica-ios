import SwiftUI
import Habitica_Models

struct EndChallengeFlow: View {
    let challenge: ChallengeProtocol
    let onClose: () -> Void
    let onFinished: () -> Void

    var body: some View {
        NavigationStack {
            EndChallengeSheet(challenge: challenge, onClose: onClose, onFinished: onFinished)
        }
    }
}

struct EndChallengeSheet: View {
    @ObservedObject private var themeService = ThemeService.shared
    let challenge: ChallengeProtocol
    let onClose: () -> Void
    let onFinished: () -> Void

    @State private var showSearch = false
    @State private var showDeleteConfirm = false
    private let socialRepository = SocialRepository()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ChallengeSheetHeader(title: L10n.endChallenge, onClose: onClose)
                    .padding(.top, 20)
                Image(uiImage: Asset.challengeGemPrize.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 215)
                    .padding(.top, 14)
                Text(L10n.endChallengeSelectWinnerTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
                    .padding(.top, 18)
                Text(L10n.endChallengeSelectWinnerBody)
                    .font(.system(size: 17))
                    .foregroundStyle(ChallengeTheme.handle)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 310)
                    .padding(.top, 8)
                HabiticaButtonUI(label: Text(L10n.endChallengeSelectWinnerButton), color: ChallengeTheme.purple) {
                    showSearch = true
                }
                .padding(.horizontal, 18)
                .padding(.top, 22)
                orDivider
                    .padding(.horizontal, 42)
                    .padding(.top, 24)
                Text(L10n.deleteChallengeTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(ChallengeTheme.deleteRed)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 310)
                    .padding(.top, 20)
                Text(L10n.deleteChallengeBody)
                    .font(.system(size: 17))
                    .foregroundStyle(ChallengeTheme.handle)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 310)
                    .padding(.top, 9)
                HabiticaButtonUI(label: Text(L10n.deleteChallengeButton), color: ChallengeTheme.deleteRed) {
                    showDeleteConfirm = true
                }
                .padding(.horizontal, 18)
                .padding(.top, 22)
                Spacer(minLength: 24)
            }
        }
        .navigationDestination(isPresented: $showSearch) {
            AwardWinnerSearchView(challenge: challenge, onClose: onClose, onFinished: onFinished)
        }
        .alert(L10n.deleteChallengeTitle, isPresented: $showDeleteConfirm) {
            Button(L10n.cancel, role: .cancel) {}
            Button(L10n.deleteChallengeButton, role: .destructive) { deleteChallenge() }
        } message: {
            Text(L10n.deleteChallengeBody)
        }
        .background(Color(themeService.theme.contentBackgroundColor).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var orDivider: some View {
        HStack(spacing: 14) {
            Rectangle().fill(Color(themeService.theme.offsetBackgroundColor)).frame(height: 1)
            Text(L10n.or)
                .font(.system(size: 13, weight: .semibold))
                .textCase(.uppercase)
                .tracking(0.4)
                .foregroundStyle(ChallengeTheme.username)
            Rectangle().fill(Color(themeService.theme.offsetBackgroundColor)).frame(height: 1)
        }
    }

    private func deleteChallenge() {
        socialRepository.deleteChallenge(challengeID: challenge.id ?? "").observeValues { _ in }
        onFinished()
    }
}

struct AwardWinnerSearchView: View {
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
            VStack(spacing: 0) {
                ChallengeSheetHeader(title: L10n.awardWinner, onClose: onClose)
                    .padding(.top, 20)
                Image(uiImage: Asset.challengeGemPrize.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 215)
                    .padding(.top, 14)
                Text(L10n.selectWinnerFromParticipants)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 26)
                    .padding(.top, 16)
                ChallengeParticipantSearch(searchText: $searchText, members: membersVM.filtered(searchText)) { member in
                    selectedMember = ChallengeMemberBox(member: member)
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                Spacer(minLength: 24)
            }
        }
        .navigationDestination(item: $selectedMember) { box in
            AwardWinnerPlayerView(challenge: challenge, member: box.member, onClose: onClose, onFinished: onFinished)
        }
        .background(Color(themeService.theme.contentBackgroundColor).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct AwardWinnerPlayerView: View {
    @ObservedObject private var themeService = ThemeService.shared
    let challenge: ChallengeProtocol
    let member: MemberProtocol
    let onClose: () -> Void
    let onFinished: () -> Void

    @StateObject private var progressVM: ChallengeMemberProgressViewModel

    init(challenge: ChallengeProtocol, member: MemberProtocol, onClose: @escaping () -> Void, onFinished: @escaping () -> Void) {
        self.challenge = challenge
        self.member = member
        self.onClose = onClose
        self.onFinished = onFinished
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
            ChallengeAwardWinnerBar(challenge: challenge, member: member, onAwarded: onFinished)
        }
        .background(Color(themeService.theme.contentBackgroundColor).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}
