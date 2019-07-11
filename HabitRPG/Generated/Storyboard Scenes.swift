// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum BuyModal: StoryboardType {
    internal static let storyboardName = "BuyModal"

    internal static let initialScene = InitialSceneType<Habitica.HRPGBuyItemModalViewController>(storyboard: BuyModal.self)

    internal static let gemCapReachedViewController = SceneType<Habitica.HRPGGemCapReachedViewController>(storyboard: BuyModal.self, identifier: "GemCapReachedViewController")

    internal static let hrpgBuyItemModalViewController = SceneType<Habitica.HRPGBuyItemModalViewController>(storyboard: BuyModal.self, identifier: "HRPGBuyItemModalViewController")

    internal static let insufficientGemsViewController = SceneType<Habitica.HRPGInsufficientGemsViewController>(storyboard: BuyModal.self, identifier: "InsufficientGemsViewController")

    internal static let insufficientGoldViewController = SceneType<Habitica.HRPGInsufficientGoldViewController>(storyboard: BuyModal.self, identifier: "InsufficientGoldViewController")

    internal static let insufficientHourglassesViewController = SceneType<Habitica.HRPGInsufficientHourglassesViewController>(storyboard: BuyModal.self, identifier: "InsufficientHourglassesViewController")
  }
  internal enum Intro: StoryboardType {
    internal static let storyboardName = "Intro"

    internal static let initialScene = InitialSceneType<Habitica.LoadingViewController>(storyboard: Intro.self)

    internal static let loginTableViewController = SceneType<Habitica.LoginTableViewController>(storyboard: Intro.self, identifier: "LoginTableViewController")
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let aboutViewController = SceneType<Habitica.AboutViewController>(storyboard: Main.self, identifier: "AboutViewController")

    internal static let avatarOverviewViewController = SceneType<Habitica.AvatarOverviewViewController>(storyboard: Main.self, identifier: "AvatarOverviewViewController")

    internal static let equipmentOverviewViewController = SceneType<Habitica.EquipmentOverviewViewController>(storyboard: Main.self, identifier: "EquipmentOverviewViewController")

    internal static let faqOverviewViewController = SceneType<Habitica.FAQTableViewController>(storyboard: Main.self, identifier: "FAQOverviewViewController")

    internal static let gemPurchaseViewController = SceneType<Habitica.GemViewController>(storyboard: Main.self, identifier: "GemPurchaseViewController")

    internal static let giftSubscriptionNavController = SceneType<UIKit.UINavigationController>(storyboard: Main.self, identifier: "GiftSubscriptionNavController")

    internal static let giftSubscriptionViewController = SceneType<Habitica.GiftSubscriptionViewController>(storyboard: Main.self, identifier: "GiftSubscriptionViewController")

    internal static let itemNavigationController = SceneType<UIKit.UINavigationController>(storyboard: Main.self, identifier: "ItemNavigationController")

    internal static let itemsViewController = SceneType<Habitica.ItemsViewController>(storyboard: Main.self, identifier: "ItemsViewController")

    internal static let mainTabBarController = SceneType<Habitica.MainTabBarController>(storyboard: Main.self, identifier: "MainTabBarController")

    internal static let mountsOverviewViewController = SceneType<Habitica.MountOverviewViewController>(storyboard: Main.self, identifier: "MountsOverviewViewController")

    internal static let newsViewController = SceneType<Habitica.NewsViewController>(storyboard: Main.self, identifier: "NewsViewController")

    internal static let petsOverviewViewController = SceneType<Habitica.PetOverviewViewController>(storyboard: Main.self, identifier: "PetsOverviewViewController")

    internal static let purchaseGemNavController = SceneType<HRPGGemHeaderNavigationController>(storyboard: Main.self, identifier: "PurchaseGemNavController")

    internal static let scanQRCodeNavController = SceneType<UIKit.UINavigationController>(storyboard: Main.self, identifier: "ScanQRCodeNavController")

    internal static let spellUserNavigationController = SceneType<UIKit.UINavigationController>(storyboard: Main.self, identifier: "SpellUserNavigationController")

    internal static let stableViewController = SceneType<Habitica.StableSplitViewController>(storyboard: Main.self, identifier: "StableViewController")

    internal static let subscriptionViewController = SceneType<Habitica.SubscriptionViewController>(storyboard: Main.self, identifier: "SubscriptionViewController")

    internal static let spellTaskNavigationController = SceneType<UIKit.UINavigationController>(storyboard: Main.self, identifier: "spellTaskNavigationController")

    internal static let tagNavigationController = SceneType<HRPGNavigationController>(storyboard: Main.self, identifier: "tagNavigationController")
  }
  internal enum Settings: StoryboardType {
    internal static let storyboardName = "Settings"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Settings.self)

    internal static let authenticationSettingsViewController = SceneType<Habitica.AuthenticationSettingsViewController>(storyboard: Settings.self, identifier: "AuthenticationSettingsViewController")

    internal static let classSelectionNavigationController = SceneType<UIKit.UINavigationController>(storyboard: Settings.self, identifier: "ClassSelectionNavigationController")
  }
  internal enum Shop: StoryboardType {
    internal static let storyboardName = "Shop"

    internal static let initialScene = InitialSceneType<HRPGShopViewController>(storyboard: Shop.self)
  }
  internal enum Shops: StoryboardType {
    internal static let storyboardName = "Shops"

    internal static let initialScene = InitialSceneType<HRPGShopOverviewViewController>(storyboard: Shops.self)
  }
  internal enum Social: StoryboardType {
    internal static let storyboardName = "Social"

    internal static let challengeDetailViewController = SceneType<Habitica.ChallengeDetailsTableViewController>(storyboard: Social.self, identifier: "ChallengeDetailViewController")

    internal static let challengeNavigationViewController = SceneType<UIKit.UINavigationController>(storyboard: Social.self, identifier: "ChallengeNavigationViewController")

    internal static let challengeTableViewController = SceneType<Habitica.ChallengeTableViewController>(storyboard: Social.self, identifier: "ChallengeTableViewController")

    internal static let groupTableViewController = SceneType<Habitica.SplitSocialViewController>(storyboard: Social.self, identifier: "GroupTableViewController")

    internal static let guidelinesNavigationViewController = SceneType<UIKit.UINavigationController>(storyboard: Social.self, identifier: "GuidelinesNavigationViewController")

    internal static let guidelinesViewController = SceneType<Habitica.GuidelinesViewController>(storyboard: Social.self, identifier: "GuidelinesViewController")

    internal static let guildsOverviewViewController = SceneType<Habitica.GuildOverviewViewController>(storyboard: Social.self, identifier: "GuildsOverviewViewController")

    internal static let inboxChatViewController = SceneType<HRPGInboxChatViewController>(storyboard: Social.self, identifier: "InboxChatViewController")

    internal static let inboxNavigationViewController = SceneType<UIKit.UINavigationController>(storyboard: Social.self, identifier: "InboxNavigationViewController")

    internal static let inboxViewController = SceneType<HRPGInboxTableViewController>(storyboard: Social.self, identifier: "InboxViewController")

    internal static let partyNavigationViewController = SceneType<UIKit.UINavigationController>(storyboard: Social.self, identifier: "PartyNavigationViewController")

    internal static let partyViewController = SceneType<Habitica.PartyViewController>(storyboard: Social.self, identifier: "PartyViewController")

    internal static let questDetailViewController = SceneType<Habitica.QuestDetailViewController>(storyboard: Social.self, identifier: "QuestDetailViewController")

    internal static let tavernChatViewController = SceneType<Habitica.GroupChatViewController>(storyboard: Social.self, identifier: "TavernChatViewController")

    internal static let tavernNavigationViewController = SceneType<UIKit.UINavigationController>(storyboard: Social.self, identifier: "TavernNavigationViewController")

    internal static let tavernViewController = SceneType<Habitica.TavernViewController>(storyboard: Social.self, identifier: "TavernViewController")

    internal static let userProfileViewController = SceneType<Habitica.UserProfileViewController>(storyboard: Social.self, identifier: "UserProfileViewController")
  }
  internal enum Tasks: StoryboardType {
    internal static let storyboardName = "Tasks"

    internal static let taskFormViewController = SceneType<Habitica.TaskFormVisualEffectsModalViewController>(storyboard: Tasks.self, identifier: "TaskFormViewController")
  }
  internal enum User: StoryboardType {
    internal static let storyboardName = "User"

    internal static let attributePointsViewController = SceneType<Habitica.AttributePointsViewController>(storyboard: User.self, identifier: "AttributePointsViewController")

    internal static let spellsViewController = SceneType<HRPGSpellViewController>(storyboard: User.self, identifier: "SpellsViewController")

    internal static let verifyUsernameModalViewController = SceneType<Habitica.VerifyUsernameModalViewController>(storyboard: User.self, identifier: "VerifyUsernameModalViewController")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
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
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

private final class BundleToken {}
