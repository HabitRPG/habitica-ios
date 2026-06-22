import SwiftUI

struct RebirthConfirmationContent: View {
    @ObservedObject var themeService = ThemeService.shared

    let gemCost: Int

    private let resetItems = [
        L10n.Shops.rebirthConfirmResetItem1,
        L10n.Shops.rebirthConfirmResetItem2,
        L10n.Shops.rebirthConfirmResetItem3,
        L10n.Shops.rebirthConfirmResetItem4
    ]

    private let keepItems = [
        L10n.Shops.rebirthConfirmKeepItem1,
        L10n.Shops.rebirthConfirmKeepItem2,
        L10n.Shops.rebirthConfirmKeepItem3,
        L10n.Shops.rebirthConfirmKeepItem4
    ]

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Shops.rebirthConfirmResetHeader)
                    .scaledFont(size: 16)
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
                    .frame(maxWidth: .infinity)
                ForEach(resetItems, id: \.self) { item in
                    Text("\u{2022} \(item)")
                        .scaledFont(size: 14)
                        .foregroundStyle(Color(themeService.theme.ternaryTextColor))
                }

                Spacer().frame(height: 12)

                Text(L10n.Shops.rebirthConfirmKeepHeader)
                    .scaledFont(size: 16)
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
                    .frame(maxWidth: .infinity)
                ForEach(keepItems, id: \.self) { item in
                    Text("\u{2022} \(item)")
                        .scaledFont(size: 14)
                        .foregroundStyle(Color(themeService.theme.ternaryTextColor))
                }
            }

            HStack(spacing: 4) {
                Image(uiImage: HabiticaIcons.imageOfGem)
                Text("\(gemCost)")
                    .scaledFont(size: 18, weight: .bold)
                    .foregroundStyle(themeService.theme.isDark ? Color.green500 : Color.green1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.green100.opacity(0.3))
            .clipShape(Capsule())
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    RebirthConfirmationContent(gemCost: 6)
}
