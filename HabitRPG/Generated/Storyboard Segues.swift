// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Segues

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
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
    case castTaskSpellSegue = "CastTaskSpellSegue"
    case castUserSpellSegue = "CastUserSpellSegue"
    case challengesSegue = "ChallengesSegue"
    case customizationSegue = "CustomizationSegue"
    case detailSegue = "DetailSegue"
    case equipmentSegue = "EquipmentSegue"
    case faqDetailSegue = "FAQDetailSegue"
    case faqSegue = "FAQSegue"
    case feedSegue = "FeedSegue"
    case filterSegue = "FilterSegue"
    case formSegue = "FormSegue"
    case gemSubscriptionSegue = "GemSubscriptionSegue"
    case guildsSegue = "GuildsSegue"
    case inboxSegue = "InboxSegue"
    case itemSegue = "ItemSegue"
    case mountDetailSegue = "MountDetailSegue"
    case newsSegue = "NewsSegue"
    case notificationsSegue = "NotificationsSegue"
    case partySegue = "PartySegue"
    case petDetailSegue = "PetDetailSegue"
    case scannedCodeSegue = "ScannedCodeSegue"
    case settingsSegue = "SettingsSegue"
    case shopsSegue = "ShopsSegue"
    case showShopSegue = "ShowShopSegue"
    case spellsSegue = "SpellsSegue"
    case stableSegue = "StableSegue"
    case statsSegue = "StatsSegue"
    case tavernSegue = "TavernSegue"
    case equipmentDetailSegue
    case openGiftGemDialog
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
    case challengesSegue = "ChallengesSegue"
    case chatSegue = "ChatSegue"
    case formSegue = "FormSegue"
    case guidelinesSegue = "GuidelinesSegue"
    case invitationSegue = "InvitationSegue"
    case questDetailSegue = "QuestDetailSegue"
    case selectedRecipientSegue = "SelectedRecipientSegue"
    case sendMessageSegue = "SendMessageSegue"
    case showGuildSegue = "ShowGuildSegue"
    case userProfileSegue = "UserProfileSegue"
    case writeMessageSegue = "WriteMessageSegue"
    case challengeDetailsSegue
  }
  internal enum Tasks: String, SegueType {
    case embedSegue = "EmbedSegue"
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol SegueType: RawRepresentable {}

internal extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

internal extension SegueType where RawValue == String {
  init?(_ segue: UIStoryboardSegue) {
    guard let identifier = segue.identifier else { return nil }
    self.init(rawValue: identifier)
  }
}

private final class BundleToken {}
