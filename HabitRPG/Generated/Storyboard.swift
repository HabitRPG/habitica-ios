// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

internal struct SceneType<T: Any> {
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

internal struct InitialSceneType<T: Any> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal protocol SegueType: RawRepresentable { }

internal extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

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

    internal static let aboutViewController = SceneType<HRPGAboutViewController>(storyboard: Main.self, identifier: "AboutViewController")

    internal static let faqOverviewViewController = SceneType<Habitica.FAQTableViewController>(storyboard: Main.self, identifier: "FAQOverviewViewController")

    internal static let gemPurchaseViewController = SceneType<Habitica.GemViewController>(storyboard: Main.self, identifier: "GemPurchaseViewController")

    internal static let itemNavigationController = SceneType<UINavigationController>(storyboard: Main.self, identifier: "ItemNavigationController")

    internal static let mainTabBarController = SceneType<HRPGTabBarController>(storyboard: Main.self, identifier: "MainTabBarController")

    internal static let purchaseGemNavController = SceneType<HRPGGemHeaderNavigationController>(storyboard: Main.self, identifier: "PurchaseGemNavController")

    internal static let scanQRCodeNavController = SceneType<UINavigationController>(storyboard: Main.self, identifier: "ScanQRCodeNavController")

    internal static let selectClassNavigationController = SceneType<UINavigationController>(storyboard: Main.self, identifier: "SelectClassNavigationController")

    internal static let spellUserNavigationController = SceneType<UINavigationController>(storyboard: Main.self, identifier: "SpellUserNavigationController")

    internal static let subscriptionViewController = SceneType<Habitica.SubscriptionViewController>(storyboard: Main.self, identifier: "SubscriptionViewController")

    internal static let spellTaskNavigationController = SceneType<UINavigationController>(storyboard: Main.self, identifier: "spellTaskNavigationController")

    internal static let tagNavigationController = SceneType<HRPGNavigationController>(storyboard: Main.self, identifier: "tagNavigationController")
  }
  internal enum Settings: StoryboardType {
    internal static let storyboardName = "Settings"

    internal static let initialScene = InitialSceneType<UINavigationController>(storyboard: Settings.self)
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

    internal static let challengeNavigationViewController = SceneType<UINavigationController>(storyboard: Social.self, identifier: "ChallengeNavigationViewController")

    internal static let challengeTableViewController = SceneType<Habitica.ChallengeTableViewController>(storyboard: Social.self, identifier: "ChallengeTableViewController")

    internal static let groupDetailTableViewController = SceneType<HRPGGroupTableViewController>(storyboard: Social.self, identifier: "GroupDetailTableViewController")

    internal static let groupTableViewController = SceneType<Habitica.SplitSocialViewController>(storyboard: Social.self, identifier: "GroupTableViewController")

    internal static let guildsOverviewViewController = SceneType<HRPGGuildsOverviewViewController>(storyboard: Social.self, identifier: "GuildsOverviewViewController")

    internal static let inboxChatViewController = SceneType<HRPGInboxChatViewController>(storyboard: Social.self, identifier: "InboxChatViewController")

    internal static let inboxNavigationViewController = SceneType<UINavigationController>(storyboard: Social.self, identifier: "InboxNavigationViewController")

    internal static let inboxViewController = SceneType<HRPGInboxTableViewController>(storyboard: Social.self, identifier: "InboxViewController")

    internal static let messageViewController = SceneType<HRPGNavigationController>(storyboard: Social.self, identifier: "MessageViewController")

    internal static let partyDetailViewController = SceneType<HRPGPartyTableViewController>(storyboard: Social.self, identifier: "PartyDetailViewController")

    internal static let partyNavigationViewController = SceneType<UINavigationController>(storyboard: Social.self, identifier: "PartyNavigationViewController")

    internal static let partyViewController = SceneType<Habitica.PartyViewController>(storyboard: Social.self, identifier: "PartyViewController")

    internal static let questDetailViewController = SceneType<HRPGQuestDetailViewController>(storyboard: Social.self, identifier: "QuestDetailViewController")

    internal static let tavernChatViewController = SceneType<Habitica.GroupChatViewController>(storyboard: Social.self, identifier: "TavernChatViewController")

    internal static let tavernNavigationViewController = SceneType<UINavigationController>(storyboard: Social.self, identifier: "TavernNavigationViewController")

    internal static let tavernViewController = SceneType<Habitica.TavernViewController>(storyboard: Social.self, identifier: "TavernViewController")

    internal static let userProfileViewController = SceneType<HRPGUserProfileViewController>(storyboard: Social.self, identifier: "UserProfileViewController")

    internal static let questInvitationNavigationController = SceneType<HRPGNavigationController>(storyboard: Social.self, identifier: "questInvitationNavigationController")
  }
  internal enum Tasks: StoryboardType {
    internal static let storyboardName = "Tasks"

    internal static let taskFormViewController = SceneType<Habitica.TaskFormVisualEffectsModalViewController>(storyboard: Tasks.self, identifier: "TaskFormViewController")
  }
  internal enum User: StoryboardType {
    internal static let storyboardName = "User"

    internal static let attributePointsViewController = SceneType<Habitica.AttributePointsViewController>(storyboard: User.self, identifier: "AttributePointsViewController")

    internal static let spellsViewController = SceneType<HRPGSpellViewController>(storyboard: User.self, identifier: "SpellsViewController")
  }
}

internal enum StoryboardSegue {
  internal enum BuyModal: String, SegueType {
    case gemCapReached
    case insufficientGems
    case insufficientGold
    case insufficientHourglasses
  }
  internal enum Intro: String, SegueType {
    case avatarSegue = "AvatarSegue"
    case initialSegue = "InitialSegue"
    case introSegue = "IntroSegue"
    case loginSegue = "LoginSegue"
    case mainSegue = "MainSegue"
    case oauthWebViewSegue = "OauthWebViewSegue"
    case setupSegue = "SetupSegue"
    case taskSegue = "TaskSegue"
    case welcomeSegue = "WelcomeSegue"
  }
  internal enum Main: String, SegueType {
    case aboutSegue = "AboutSegue"
    case castUserSpellSegue = "CastUserSpellSegue"
    case customizationSegue = "CustomizationSegue"
    case detailSegue = "DetailSegue"
    case equipmentDetailSegue = "EquipmentDetailSegue"
    case equipmentSegue = "EquipmentSegue"
    case faqDetailSegue = "FAQDetailSegue"
    case faqSegue = "FAQSegue"
    case feedSegue = "FeedSegue"
    case filterSegue = "FilterSegue"
    case formSegue = "FormSegue"
    case groupBySegue = "GroupBySegue"
    case helpSegue = "HelpSegue"
    case itemSegue = "ItemSegue"
    case mountSegue = "MountSegue"
    case newsSegue = "NewsSegue"
    case petSegue = "PetSegue"
    case scannedCodeSegue = "ScannedCodeSegue"
    case selectClassSegue = "SelectClassSegue"
    case settingsSegue = "SettingsSegue"
    case shopsSegue = "ShopsSegue"
    case showShopSegue = "ShowShopSegue"
    case unwindTagSegue = "UnwindTagSegue"
    case unwindSaveSegue
    case unwindSegue
  }
  internal enum Settings: String, SegueType {
    case apiSegue = "APISegue"
    case authenticationSegue = "AuthenticationSegue"
    case fixValuesSegue = "FixValuesSegue"
    case profileSegue = "ProfileSegue"
  }
  internal enum Shop: String, SegueType {
    case buyModal
  }
  internal enum Shops: String, SegueType {
    case shopSegue = "ShopSegue"
  }
  internal enum Social: String, SegueType {
    case aboutSegue = "AboutSegue"
    case challengeSegue = "ChallengeSegue"
    case chatSegue = "ChatSegue"
    case groupFormSegue = "GroupFormSegue"
    case guidelinesSegue = "GuidelinesSegue"
    case invitationSegue = "InvitationSegue"
    case membersSegue = "MembersSegue"
    case messageSegue = "MessageSegue"
    case participantsSegue = "ParticipantsSegue"
    case questDetailSegue = "QuestDetailSegue"
    case selectedRecipientSegue = "SelectedRecipientSegue"
    case showGuildSegue = "ShowGuildSegue"
    case userProfileSegue = "UserProfileSegue"
    case writeMessageSegue = "WriteMessageSegue"
    case challengeDetailsSegue
    case unwindSaveSegue
  }
  internal enum Tasks: String, SegueType {
    case embedSegue = "EmbedSegue"
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}
