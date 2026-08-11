import SwiftUI

struct RebirthEnabledSheet: View {
    @ObservedObject var themeService = ThemeService.shared
    @Environment(\.presentationManager)
    var presentationManager

    var body: some View {
        GamifiedBottomSheet(upperBackgroundColor: .yellow100,
                            upperContent: VStack {
            FanfareContainer(haloColor: .yellow500,
                             outerRingColor: .yellow500,
                             plusColor: .yellow10, content: {
                PixelArtView(name: "rebirth_orb")
                    .frame(width: 72, height: 72)
            })
            Text(L10n.Shops.rebirthEnabledTitle)
                .scaledFont(size: 22, weight: .bold)
                .foregroundStyle(Color.orange1)
                .padding(.horizontal, 50)
                .fixedSize(horizontal: false, vertical: true)
        }, title: Text(L10n.Shops.rebirthEnabledSubtitle),
                            description: Text(L10n.Shops.rebirthEnabledDescription), buttons: {
            HabiticaButtonUI(label: Text(L10n.onwards), color: Color(themeService.theme.fixedTintColor)) {
                presentationManager.dismiss()
            }
            HabiticaButtonUI(label: Text(L10n.Shops.goToMarket).foregroundStyle(Color(themeService.theme.primaryTextColor)), color: Color(themeService.theme.offsetBackgroundColor)) {
                RouterHandler.shared.handle(.market)
                presentationManager.dismiss()
            }
        })
    }
}

#Preview {
    RebirthEnabledSheet()
}
