import SwiftUI
import Habitica_Models

struct ChallengeListCard: View {
    @ObservedObject private var themeService = ThemeService.shared
    let challenge: ChallengeProtocol
    let isParticipating: Bool
    let isOwner: Bool

    private var countColor: Color {
        isParticipating ? Color(red: 0x24 / 255, green: 0xA5 / 255, blue: 0x74 / 255) : Color(themeService.theme.secondaryTextColor)
    }

    private var categoryNames: [String] {
        challenge.categories
            .compactMap { $0.name }
            .filter { $0 != ChallengeCategory.official.rawValue }
            .compactMap { ChallengeCategory.localizedCategoryNameFor(name: $0) }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 5) {
                if isOwner {
                    Image(uiImage: Asset.crown.image)
                        .resizable().scaledToFit().frame(width: 20)
                }
                Image(uiImage: Asset.bigGem.image)
                    .resizable().scaledToFit().frame(width: 31, height: 26)
                Text("\(challenge.prize)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(themeService.theme.secondaryTextColor))
            }
            .frame(width: 36)
            VStack(alignment: .leading, spacing: 0) {
                Text(challenge.name?.unicodeEmoji ?? "")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
                    .fixedSize(horizontal: false, vertical: true)
                if let summary = challenge.summary?.unicodeEmoji, !summary.isEmpty {
                    Text(summary)
                        .font(.system(size: 13.5))
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
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var metaRow: some View {
        HStack(spacing: 8) {
            HStack(spacing: 5) {
                Image(uiImage: Asset.memberCountIcon.image)
                    .renderingMode(.template)
                    .resizable().scaledToFit().frame(width: 19, height: 14)
                    .foregroundStyle(countColor)
                Text("\(challenge.memberCount)")
                    .font(.system(size: 13.5, weight: isParticipating ? .bold : .semibold))
                    .foregroundStyle(countColor)
            }
            if challenge.official {
                pill(text: L10n.official, background: .purple300, foreground: .white)
            }
            if let name = categoryNames.first {
                pill(text: name, background: .gray500, foreground: .gray200)
            }
            Spacer(minLength: 0)
        }
    }

    private func pill(text: String, background: Color, foreground: Color) -> some View {
        Text(text)
            .font(.system(size: 12.5, weight: .semibold))
            .foregroundStyle(foreground)
            .lineLimit(1)
            .fixedSize()
            .padding(.vertical, 4)
            .padding(.horizontal, 11)
            .background(background)
            .clipShape(Capsule())
    }
}
