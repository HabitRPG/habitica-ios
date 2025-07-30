// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length implicit_return

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length prefer_self_in_static_references
// swiftlint:disable type_body_length type_name
internal enum StoryboardScene {
  internal enum BuyModal: StoryboardType {
    internal static let storyboardName = "BuyModal"

    internal static let initialScene = InitialSceneType<HRPGBuyItemModalViewController>(storyboard: BuyModal.self)

    internal static let hrpgBuyItemModalViewController = SceneType<HRPGBuyItemModalViewController>(storyboard: BuyModal.self, identifier: "HRPGBuyItemModalViewController")
  }
  internal enum Intro: StoryboardType {
    internal static let storyboardName = "Intro"

    internal static let initialScene = InitialSceneType<LoadingViewController>(storyboard: Intro.self)

    internal static let loginTableViewController = SceneType<LoginTableViewController>(storyboard: Intro.self, identifier: "LoginTableViewController")
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let aboutViewController = SceneType<AboutViewController>(storyboard: Main.self, identifier: "AboutViewController")

    internal static let adventureGuideNavigationViewController = SceneType<UIKit.UINavigationController>(storyboard: Main.self, identifier: "AdventureGuideNavigationViewController")

    internal static let adventureGuideViewController = SceneType<AdventureGuideViewController>(storyboard: Main.self, identifier: "AdventureGuideViewController")

    internal static let avatarOverviewViewController = SceneType<AvatarOverviewViewController>(storyboard: Main.self, identifier: "AvatarOverviewViewController")

    internal static let dailiesViewController = SceneType<DailyTableViewController>(storyboard: Main.self, identifier: "DailiesViewController")

    internal static let equipmentOverviewViewController = SceneType<EquipmentOverviewViewController>(storyboard: Main.self, identifier: "EquipmentOverviewViewController")

    internal static let gemPurchaseViewController = SceneType<GemViewController>(storyboard: Main.self, identifier: "GemPurchaseViewController")

    internal static let giftGemsNavController = SceneType<ThemedNavigationController>(storyboard: Main.self, identifier: "GiftGemsNavController")

    internal static let giftSubscriptionNavController = SceneType<ThemedNavigationController>(storyboard: Main.self, identifier: "GiftSubscriptionNavController")

    internal static let giftSubscriptionViewController = SceneType<GiftSubscriptionViewController>(storyboard: Main.self, identifier: "GiftSubscriptionViewController")

    internal static let habitsViewController = SceneType<HabitTableViewController>(storyboard: Main.self, identifier: "HabitsViewController")

    internal static let itemNavigationController = SceneType<UIKit.UINavigationController>(storyboard: Main.self, identifier: "ItemNavigationController")

    internal static let itemsViewController = SceneType<ItemsViewController>(storyboard: Main.self, identifier: "ItemsViewController")

    internal static let mainSplitViewController = SceneType<UIKit.UISplitViewController>(storyboard: Main.self, identifier: "MainSplitViewController")

    internal static let mainTabBarController = SceneType<MainTabBarController>(storyboard: Main.self, identifier: "MainTabBarController")

    internal static let mountDetailViewController = SceneType<MountDetailViewController>(storyboard: Main.self, identifier: "MountDetailViewController")

    internal static let mountsOverviewViewController = SceneType<MountOverviewViewController>(storyboard: Main.self, identifier: "MountsOverviewViewController")

    internal static let newsViewController = SceneType<NewsViewController>(storyboard: Main.self, identifier: "NewsViewController")

    internal static let notificationsNavigationController = SceneType<ThemedNavigationController>(storyboard: Main.self, identifier: "NotificationsNavigationController")

    internal static let petDetailViewController = SceneType<PetDetailViewController>(storyboard: Main.self, identifier: "PetDetailViewController")

    internal static let petsOverviewViewController = SceneType<PetOverviewViewController>(storyboard: Main.self, identifier: "PetsOverviewViewController")

    internal static let promoWebNavController = SceneType<UIKit.UINavigationController>(storyboard: Main.self, identifier: "PromoWebNavController")

    internal static let promoWebViewController = SceneType<PromoWebViewController>(storyboard: Main.self, identifier: "PromoWebViewController")

    internal static let promotionInfoNavController = SceneType<UIKit.UINavigationController>(storyboard: Main.self, identifier: "PromotionInfoNavController")

    internal static let promotionInfoViewController = SceneType<PromotionInfoViewController>(storyboard: Main.self, identifier: "PromotionInfoViewController")

    internal static let purchaseGemNavController = SceneType<UIKit.UINavigationController>(storyboard: Main.self, identifier: "PurchaseGemNavController")

    internal static let rewardsViewController = SceneType<RewardViewController>(storyboard: Main.self, identifier: "RewardsViewController")

    internal static let spellUserNavigationController = SceneType<UIKit.UINavigationController>(storyboard: Main.self, identifier: "SpellUserNavigationController")

    internal static let stableViewController = SceneType<StableSplitViewController>(storyboard: Main.self, identifier: "StableViewController")

    internal static let subscriptionNavController = SceneType<UIKit.UINavigationController>(storyboard: Main.self, identifier: "SubscriptionNavController")

    internal static let taskBoardViewController = SceneType<UIKit.UIViewController>(storyboard: Main.self, identifier: "TaskBoardViewController")

    internal static let todosViewController = SceneType<ToDoTableViewController>(storyboard: Main.self, identifier: "TodosViewController")

    internal static let avatarDetailViewController = SceneType<AvatarDetailViewController>(storyboard: Main.self, identifier: "avatarDetailViewController")

    internal static let oldAvatarDetailViewController = SceneType<OldAvatarDetailViewController>(storyboard: Main.self, identifier: "oldAvatarDetailViewController")

    internal static let spellTaskNavigationController = SceneType<UIKit.UINavigationController>(storyboard: Main.self, identifier: "spellTaskNavigationController")

    internal static let tagNavigationController = SceneType<ThemedNavigationController>(storyboard: Main.self, identifier: "tagNavigationController")
  }
  internal enum Settings: StoryboardType {
    internal static let storyboardName = "Settings"

    internal static let initialScene = InitialSceneType<ThemedNavigationController>(storyboard: Settings.self)

    internal static let classSelectionNavigationController = SceneType<UIKit.UINavigationController>(storyboard: Settings.self, identifier: "ClassSelectionNavigationController")
  }
  internal enum Shop: StoryboardType {
    internal static let storyboardName = "Shop"

    internal static let shopViewController = SceneType<ShopViewController>(storyboard: Shop.self, identifier: "ShopViewController")
  }
  internal enum Social: StoryboardType {
    internal static let storyboardName = "Social"

    internal static let challengeDetailViewController = SceneType<ChallengeDetailsTableViewController>(storyboard: Social.self, identifier: "ChallengeDetailViewController")

    internal static let challengeNavigationViewController = SceneType<ThemedNavigationController>(storyboard: Social.self, identifier: "ChallengeNavigationViewController")

    internal static let challengeTableViewController = SceneType<ChallengeTableViewController>(storyboard: Social.self, identifier: "ChallengeTableViewController")

    internal static let groupChatViewController = SceneType<GroupChatViewController>(storyboard: Social.self, identifier: "GroupChatViewController")

    internal static let groupTableViewController = SceneType<SplitSocialViewController>(storyboard: Social.self, identifier: "GroupTableViewController")

    internal static let guidelinesNavigationViewController = SceneType<ThemedNavigationController>(storyboard: Social.self, identifier: "GuidelinesNavigationViewController")

    internal static let guidelinesViewController = SceneType<GuidelinesViewController>(storyboard: Social.self, identifier: "GuidelinesViewController")

    internal static let guildsOverviewViewController = SceneType<GuildOverviewViewController>(storyboard: Social.self, identifier: "GuildsOverviewViewController")

    internal static let inboxChatNavigationController = SceneType<ThemedNavigationController>(storyboard: Social.self, identifier: "InboxChatNavigationController")

    internal static let inboxChatViewController = SceneType<InboxChatViewController>(storyboard: Social.self, identifier: "InboxChatViewController")

    internal static let inboxNavigationViewController = SceneType<ThemedNavigationController>(storyboard: Social.self, identifier: "InboxNavigationViewController")

    internal static let inboxViewController = SceneType<InboxOverviewViewController>(storyboard: Social.self, identifier: "InboxViewController")

    internal static let partyNavigationViewController = SceneType<ThemedNavigationController>(storyboard: Social.self, identifier: "PartyNavigationViewController")

    internal static let partyViewController = SceneType<PartyViewController>(storyboard: Social.self, identifier: "PartyViewController")

    internal static let questDetailViewController = SceneType<QuestDetailViewController>(storyboard: Social.self, identifier: "QuestDetailViewController")

    internal static let userProfileNavController = SceneType<UIKit.UINavigationController>(storyboard: Social.self, identifier: "UserProfileNavController")

    internal static let userProfileViewController = SceneType<UserProfileViewController>(storyboard: Social.self, identifier: "UserProfileViewController")
  }
  internal enum Support: StoryboardType {
    internal static let storyboardName = "Support"

    internal static let initialScene = InitialSceneType<MainSupportViewController>(storyboard: Support.self)

    internal static let faqDetailViewController = SceneType<FAQDetailViewController>(storyboard: Support.self, identifier: "FAQDetailViewController")

    internal static let faqViewController = SceneType<FAQViewController>(storyboard: Support.self, identifier: "FAQViewController")

    internal static let mainSupportViewController = SceneType<MainSupportViewController>(storyboard: Support.self, identifier: "MainSupportViewController")

    internal static let reportBugViewController = SceneType<ReportBugViewController>(storyboard: Support.self, identifier: "ReportBugViewController")
  }
  internal enum Tasks: StoryboardType {
    internal static let storyboardName = "Tasks"

    internal static let taskDetailViewController = SceneType<UIKit.UINavigationController>(storyboard: Tasks.self, identifier: "TaskDetailViewController")

    internal static let taskFormViewController = SceneType<ThemedNavigationController>(storyboard: Tasks.self, identifier: "TaskFormViewController")
  }
  internal enum User: StoryboardType {
    internal static let storyboardName = "User"

    internal static let achievementsCollectionViewController = SceneType<AchievementsCollectionViewController>(storyboard: User.self, identifier: "AchievementsCollectionViewController")

    internal static let attributePointsViewController = SceneType<AttributePointsViewController>(storyboard: User.self, identifier: "AttributePointsViewController")

    internal static let spellsViewController = SceneType<SpellViewController>(storyboard: User.self, identifier: "SpellsViewController")

    internal static let verifyUsernameModalViewController = SceneType<VerifyUsernameModalViewController>(storyboard: User.self, identifier: "VerifyUsernameModalViewController")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length prefer_self_in_static_references
// swiftlint:enable type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: BundleToken.bundle)
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    return storyboard.storyboard.instantiateViewController(identifier: identifier, creator: block)
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController(creator: block) else {
      fatalError("Storyboard \(storyboard.storyboardName) does not have an initial scene.")
    }
    return controller
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
