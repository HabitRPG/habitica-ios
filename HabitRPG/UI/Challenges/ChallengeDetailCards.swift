import SwiftUI
import UIKit
import Habitica_Models

struct ChallengeDetailHeaderCard: View {
    @ObservedObject private var themeService = ThemeService.shared
    let challenge: ChallengeProtocol

    var body: some View {
        VStack(spacing: 0) {
            Text(challenge.name?.unicodeEmoji ?? "")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(Color(themeService.theme.primaryTextColor))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if let shortName = challenge.shortName, !shortName.isEmpty {
                Text(L10n.taskTag(shortName))
                    .font(.system(size: 16))
                    .foregroundStyle(ChallengeTheme.counter)
                    .multilineTextAlignment(.center)
                    .padding(.top, 7)
            }
            HStack(spacing: 13) {
                statCard(image: Asset.participantsList.image,
                         value: "\(challenge.memberCount)",
                         label: L10n.participants,
                         tint: Color(red: 0x81 / 255, green: 0x58 / 255, blue: 0xD0 / 255),
                         iconSize: CGSize(width: 30, height: 30))
                statCard(image: Asset.gem.image,
                         value: "\(challenge.prize)",
                         label: L10n.prize,
                         tint: nil)
            }
            .padding(.top, 18)
        }
    }

    private func statCard(image: UIImage, value: String, label: String, tint: Color?, iconSize: CGSize = CGSize(width: 24, height: 20)) -> some View {
        VStack(spacing: 5) {
            HStack(spacing: 7) {
                Group {
                    if let tint = tint {
                        Image(uiImage: image).renderingMode(.template).resizable().scaledToFit().foregroundStyle(tint)
                    } else {
                        Image(uiImage: image).resizable().scaledToFit()
                    }
                }
                .frame(width: iconSize.width, height: iconSize.height)
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
            }
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(ChallengeTheme.sectionLabel)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(themeService.theme.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct ChallengeMarkdownView: UIViewRepresentable {
    let markdown: String

    func makeUIView(context: Context) -> MarkdownTextView {
        let view = MarkdownTextView()
        view.isScrollEnabled = false
        view.isEditable = false
        view.backgroundColor = .clear
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        return view
    }

    func updateUIView(_ uiView: MarkdownTextView, context: Context) {
        uiView.setMarkdownString(markdown.unicodeEmoji)
    }
}

struct ChallengeDetailCreatorCard: View {
    @ObservedObject private var themeService = ThemeService.shared
    let challenge: ChallengeProtocol
    let creator: MemberProtocol?
    let isOwner: Bool
    let onUserTap: () -> Void
    let onMessageTap: () -> Void

    private var showsDiamond: Bool { (creator?.contributor?.level ?? 0) > 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(L10n.challengeCreator)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(ChallengeTheme.sectionLabel)
            HStack(spacing: 13) {
                avatar
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 7) {
                        Text(creator?.profile?.name ?? challenge.leaderName ?? "")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color(red: 0x16 / 255, green: 0x7E / 255, blue: 0x87 / 255))
                        if showsDiamond {
                            Image(uiImage: HabiticaIcons.imageOfContributorBadge(tier: creator?.contributor?.level ?? 1, isNPC: false))
                                .resizable().scaledToFit().frame(width: 14, height: 13)
                        }
                    }
                    if isOwner {
                        Text(L10n.youOwnThisChallenge)
                            .font(.system(size: 15))
                            .foregroundStyle(Color(red: 0x7E / 255, green: 0x7B / 255, blue: 0x86 / 255))
                    }
                }
                Spacer(minLength: 0)
                if !isOwner {
                    Button(action: onMessageTap) {
                        Image(systemName: "envelope")
                            .font(.system(size: 19))
                            .foregroundStyle(Color(themeService.theme.primaryTextColor))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(themeService.theme.windowBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .contentShape(Rectangle())
            .onTapGesture { onUserTap() }
        }
    }

    @ViewBuilder private var avatar: some View {
        ZStack {
            if let creator = creator {
                AvatarViewUI(avatar: AvatarViewModel(avatar: creator))
                    .frame(width: 44, height: 44)
            } else {
                Circle()
                    .fill(Color(themeService.theme.offsetBackgroundColor))
                    .frame(width: 44, height: 44)
            }
            if isOwner {
                Image(uiImage: Asset.crown.image)
                    .resizable().scaledToFit().frame(width: 21)
                    .offset(y: -28)
            }
        }
        .frame(width: 44, height: 44)
    }
}

struct ChallengeDetailCategoriesCard: View {
    @ObservedObject private var themeService = ThemeService.shared
    let challenge: ChallengeProtocol

    private var chips: [(name: String, official: Bool)] {
        challenge.categories.compactMap { category in
            guard let slug = category.slug else { return nil }
            let name = ChallengeCategory(rawValue: slug)?.localizedName ?? category.name ?? slug
            return (name, slug == ChallengeCategory.official.rawValue)
        }
    }

    var body: some View {
        if !chips.isEmpty {
            VStack(alignment: .leading, spacing: 9) {
                Text(L10n.challengeCategories)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(ChallengeTheme.sectionLabel)
                ChallengeChipFlow(spacing: 9) {
                    ForEach(Array(chips.enumerated()), id: \.offset) { _, chip in
                        chipView(chip.name, official: chip.official)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(themeService.theme.windowBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }

    private func chipView(_ name: String, official: Bool) -> some View {
        Text(name)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(official ? Color.white : Color.gray200)
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
            .background(official ? Color.purple300 : Color.gray500)
            .clipShape(Capsule())
    }
}

struct ChallengeDetailDescriptionCard: View {
    @ObservedObject private var themeService = ThemeService.shared
    let challenge: ChallengeProtocol

    var body: some View {
        if let notes = challenge.notes, !notes.isEmpty {
            VStack(alignment: .leading, spacing: 9) {
                Text(L10n.challengeDescription)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(ChallengeTheme.sectionLabel)
                ChallengeMarkdownView(markdown: notes)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(themeService.theme.windowBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }
}

struct ChallengeChipFlow: Layout {
    var spacing: CGFloat = 9

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth > 0 && rowWidth + spacing + size.width > maxWidth {
                totalHeight += rowHeight + spacing
                rowWidth = size.width
                rowHeight = size.height
            } else {
                rowWidth += (rowWidth > 0 ? spacing : 0) + size.width
                rowHeight = max(rowHeight, size.height)
            }
        }
        totalHeight += rowHeight
        return CGSize(width: maxWidth == .infinity ? rowWidth : maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var posX = bounds.minX
        var posY = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if posX > bounds.minX && posX + size.width > bounds.maxX {
                posX = bounds.minX
                posY += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: posX, y: posY), proposal: ProposedViewSize(size))
            posX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
