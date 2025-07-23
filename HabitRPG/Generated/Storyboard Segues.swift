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
  internal enum Intro: String, SegueType {
    case avatarSegue = "AvatarSegue"
    case initialSegue = "InitialSegue"
    case introSegue = "IntroSegue"
    case loginSegue = "LoginSegue"
    case mainSegue = "MainSegue"
    case setupSegue = "SetupSegue"
    case taskSegue = "TaskSegue"
  }
  internal enum Main: String, SegueType {
    case aboutSegue = "AboutSegue"
    case achievementsSegue = "AchievementsSegue"
    case castTaskSpellSegue = "CastTaskSpellSegue"
    case castUserSpellSegue = "CastUserSpellSegue"
    case challengesSegue = "ChallengesSegue"
    case customizationSegue = "CustomizationSegue"
    case detailSegue = "DetailSegue"
    case equipmentSegue = "EquipmentSegue"
    case feedSegue = "FeedSegue"
    case filterSegue = "FilterSegue"
    case formSegue = "FormSegue"
    case giftGemsSegue = "GiftGemsSegue"
    case guildsSegue = "GuildsSegue"
    case inboxSegue = "InboxSegue"
    case itemSegue = "ItemSegue"
    case mountDetailSegue = "MountDetailSegue"
    case newsSegue = "NewsSegue"
    case notificationsSegue = "NotificationsSegue"
    case oldDetailSegue = "OldDetailSegue"
    case partySegue = "PartySegue"
    case petDetailSegue = "PetDetailSegue"
    case settingsSegue = "SettingsSegue"
    case showShopSegue = "ShowShopSegue"
    case spellsSegue = "SpellsSegue"
    case stableSegue = "StableSegue"
    case statsSegue = "StatsSegue"
    case equipmentDetailSegue
    case hallOfContributorsSegue
    case hallOfPatronsSegue
    case openGiftSubscriptionDialog
    case purchaseGemsSegue
    case showAdventureGuide
    case showCustomizationShopSegue
    case showMarketSegue
    case showPromoInfoSegue
    case showQuestShopSegue
    case showSeasonalShopSegue
    case showSupportSegue
    case showTimeTravelersSegue
    case showUserProfileSegue
    case showWebPromoSegue
    case subscriptionSegue
    case tasksBoardSegue
  }
  internal enum Settings: String, SegueType {
    case fixValuesSegue = "FixValuesSegue"
    case accountSegue
  }
  internal enum Shop: String, SegueType {
    case buyModal
  }
  internal enum Social: String, SegueType {
    case challengesSegue = "ChallengesSegue"
    case chatSegue = "ChatSegue"
    case formSegue = "FormSegue"
    case guidelinesSegue = "GuidelinesSegue"
    case questDetailSegue = "QuestDetailSegue"
    case selectedRecipientSegue = "SelectedRecipientSegue"
    case sendMessageSegue = "SendMessageSegue"
    case showGuildSegue = "ShowGuildSegue"
    case userProfileSegue = "UserProfileSegue"
    case writeMessageSegue = "WriteMessageSegue"
    case challengeDetailsSegue
    case findMembersSegue
    case giftGemsSegue
    case giftSubscriptionSegue
    case inviteMembersSegue
  }
  internal enum Support: String, SegueType {
    case showFAQDetailSegue
    case showKnownIssueDetailSegue
  }
  internal enum Tasks: String, SegueType {
    case formSegue = "FormSegue"
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
