import SwiftUI

struct RebirthAchievementSheet: View {
    @ObservedObject var themeService = ThemeService.shared
    @Environment(\.presentationManager)
    var presentationManager

    let rebirthCount: Int
    let rebirthLevel: Int

    private var descriptionText: String {
        if rebirthLevel >= 100 {
            return L10n.Shops.rebirthAchievementDescriptionMax(rebirthCount, 100)
        } else {
            return L10n.Shops.rebirthAchievementDescription(rebirthCount, rebirthLevel)
        }
    }

    var body: some View {
        GamifiedBottomSheet(upperBackgroundColor: .yellow100,
                            upperContent: VStack {
            FanfareContainer(haloColor: .yellow500,
                             outerRingColor: .yellow500,
                             plusColor: .yellow10, content: {
                PixelArtView(name: "achievement-sun2x")
                    .frame(width: 72, height: 72)
            })
            Text(L10n.youGotAchievement)
                .scaledFont(size: 22, weight: .bold)
                .foregroundStyle(Color.orange1)
                .padding(.horizontal, 50)
                .fixedSize(horizontal: false, vertical: true)
        }, title: Text(L10n.Shops.rebirthAchievementTitle),
                            description: Text(descriptionText), buttons: {
            HabiticaButtonUI(label: Text(L10n.viewAchievements), color: Color(themeService.theme.fixedTintColor)) {
                RouterHandler.shared.handle(.achievements)
                presentationManager.dismiss()
            }
            HabiticaButtonUI(label: Text(L10n.close).foregroundStyle(Color(themeService.theme.primaryTextColor)), color: Color(themeService.theme.offsetBackgroundColor)) {
                presentationManager.dismiss()
            }
        })
    }
}

#Preview {
    RebirthAchievementSheet(rebirthCount: 3, rebirthLevel: 55)
}
