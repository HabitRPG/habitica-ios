import SwiftUI
import Habitica_Models

struct ChallengeListCard: View {
    @ObservedObject private var themeService = ThemeService.shared
    let challenge: ChallengeProtocol
    let isParticipating: Bool
    let isOwner: Bool

    private var countColor: Color {
        isParticipating ? ChallengeTheme.joinedCount : Color(themeService.theme.secondaryTextColor)
    }

    private var categoryNames: [String] {
        challenge.categories
            .compactMap { $0.name }
            .filter { $0 != ChallengeCategory.official.rawValue }
            .compactMap { ChallengeCategory.localizedCategoryNameFor(name: $0) }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 2) {
                Image(uiImage: Asset.bigGem.image)
                    .resizable().scaledToFit().frame(width: 31, height: 26)
                Text("\(challenge.prize)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(themeService.theme.secondaryTextColor))
            }
            .overlay(alignment: .top) {
                if isOwner {
                    Image(uiImage: Asset.challengeCrown.image)
                        .resizable().scaledToFit().frame(width: 30)
                        .offset(x: 2, y: -14)
                }
            }
            .frame(width: 36)
            .frame(maxHeight: .infinity)
            .offset(y: isOwner ? 6 : 0)
            VStack(alignment: .leading, spacing: 0) {
                Text(challenge.name?.unicodeEmoji ?? "")
                    .font(.system(size: 15, weight: .semibold))
                    .tracking(-0.23)
                    .lineSpacing(2)
                    .foregroundStyle(ChallengeTheme.cardTitle)
                    .fixedSize(horizontal: false, vertical: true)
                if let summary = challenge.summary?.unicodeEmoji, !summary.isEmpty {
                    Text(summary)
                        .font(.system(size: 13))
                        .tracking(-0.08)
                        .lineSpacing(2.5)
                        .foregroundStyle(Color(themeService.theme.secondaryTextColor))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 6)
                }
                metaRow.padding(.top, 13)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(themeService.theme.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: ChallengeTheme.containerRadius, style: .continuous))
    }

    private var metaRow: some View {
        HStack(spacing: 8) {
            HStack(spacing: 5) {
                Image(uiImage: Asset.participantsList.image)
                    .renderingMode(.template)
                    .resizable().scaledToFit().frame(width: 20, height: 20)
                    .foregroundStyle(countColor)
                Text("\(challenge.memberCount)")
                    .font(.system(size: 13.5, weight: isParticipating ? .bold : .semibold))
                    .foregroundStyle(countColor)
                    .lineLimit(1)
                    .fixedSize()
            }
            if challenge.official {
                pill(text: L10n.official, background: .purple300, foreground: .white)
            }
            if let name = categoryNames.first {
                pill(text: name, background: ChallengeTheme.chipFill, foreground: ChallengeTheme.chipText, truncates: true)
            }
            Spacer(minLength: 0)
        }
    }

    private func pill(text: String, background: Color, foreground: Color, truncates: Bool = false) -> some View {
        Text(text)
            .font(.system(size: 12.5, weight: .semibold))
            .foregroundStyle(foreground)
            .lineLimit(1)
            .truncationMode(.tail)
            .fixedSize(horizontal: !truncates, vertical: true)
            .padding(.horizontal, 11)
            .frame(height: 26)
            .background(background)
            .clipShape(Capsule())
    }
}
