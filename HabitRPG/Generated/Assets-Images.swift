// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  typealias AssetColorTypeAlias = NSColor
  typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  typealias AssetColorTypeAlias = UIColor
  typealias Image = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

@available(*, deprecated, renamed: "ImageAsset")
typealias AssetType = ImageAsset

struct ImageAsset {
  fileprivate var name: String

  var image: Image {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

struct ColorAsset {
  fileprivate var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
enum Asset {
  static let _21Gems = ImageAsset(name: "21_gems")
  static let _42Gems = ImageAsset(name: "42_gems")
  static let _4Gems = ImageAsset(name: "4_gems")
  static let _84Gems = ImageAsset(name: "84_gems")
  static let bossContainer = ImageAsset(name: "BossContainer")
  static let challengeGemIcon = ImageAsset(name: "ChallengeGemIcon")
  static let chatCopy = ImageAsset(name: "ChatCopy")
  static let chatDelete = ImageAsset(name: "ChatDelete")
  static let chatReply = ImageAsset(name: "ChatReply")
  static let chatReport = ImageAsset(name: "ChatReport")
  static let close = ImageAsset(name: "Close")
  static let cloud1 = ImageAsset(name: "Cloud1")
  static let cloud2 = ImageAsset(name: "Cloud2")
  static let diamondButton = ImageAsset(name: "DiamondButton")
  static let gem = ImageAsset(name: "Gem")
  static let introPage1 = ImageAsset(name: "IntroPage1")
  static let introPage2 = ImageAsset(name: "IntroPage2")
  static let introPage3 = ImageAsset(name: "IntroPage3")
  static let introTitle = ImageAsset(name: "IntroTitle")
  static let loginBackground = ImageAsset(name: "LoginBackground")
  static let loginBeginButton = ImageAsset(name: "LoginBeginButton")
  static let loginButton = ImageAsset(name: "LoginButton")
  static let loginLogo = ImageAsset(name: "LoginLogo")
  static let logo = ImageAsset(name: "Logo")
  static let memberCountIcon = ImageAsset(name: "MemberCountIcon")
  static let menuMessages = ImageAsset(name: "MenuMessages")
  static let menuSettings = ImageAsset(name: "MenuSettings")
  static let nameplate = ImageAsset(name: "Nameplate")
  static let welcomeDiamond = ImageAsset(name: "WelcomeDiamond")
  static let bigGem = ImageAsset(name: "big_gem")
  static let calendar = ImageAsset(name: "calendar")
  static let carretDown = ImageAsset(name: "carret_down")
  static let carretUp = ImageAsset(name: "carret_up")
  static let categoryBody = ImageAsset(name: "category_body")
  static let categoryExtras = ImageAsset(name: "category_extras")
  static let categoryHair = ImageAsset(name: "category_hair")
  static let categorySelectionCaret = ImageAsset(name: "category_selection_caret")
  static let categorySkin = ImageAsset(name: "category_skin")
  static let challenge = ImageAsset(name: "challenge")
  static let checkboxChecked = ImageAsset(name: "checkbox_checked")
  static let checkboxUnchecked = ImageAsset(name: "checkbox_unchecked")
  static let checkmarkSmall = ImageAsset(name: "checkmark_small")
  static let circleSelected = ImageAsset(name: "circle_selected")
  static let circleUnselected = ImageAsset(name: "circle_unselected")
  static let creatorActivePixelArrowLeft = ImageAsset(name: "creator_active_pixel_arrow_left")
  static let creatorActivePixelArrowRight = ImageAsset(name: "creator_active_pixel_arrow_right")
  static let creatorBlankFace = ImageAsset(name: "creator_blank_face")
  static let creatorBroadShirtBlack = ImageAsset(name: "creator_broad_shirt_black")
  static let creatorBroadShirtBlue = ImageAsset(name: "creator_broad_shirt_blue")
  static let creatorBroadShirtGreen = ImageAsset(name: "creator_broad_shirt_green")
  static let creatorBroadShirtPink = ImageAsset(name: "creator_broad_shirt_pink")
  static let creatorBroadShirtWhite = ImageAsset(name: "creator_broad_shirt_white")
  static let creatorBroadShirtYellow = ImageAsset(name: "creator_broad_shirt_yellow")
  static let creatorChairBlack = ImageAsset(name: "creator_chair_black")
  static let creatorChairBlue = ImageAsset(name: "creator_chair_blue")
  static let creatorChairGreen = ImageAsset(name: "creator_chair_green")
  static let creatorChairPink = ImageAsset(name: "creator_chair_pink")
  static let creatorChairRed = ImageAsset(name: "creator_chair_red")
  static let creatorChairYellow = ImageAsset(name: "creator_chair_yellow")
  static let creatorEyewearSpecialBlacktopframe = ImageAsset(name: "creator_eyewear_special_blacktopframe")
  static let creatorEyewearSpecialBluetopframe = ImageAsset(name: "creator_eyewear_special_bluetopframe")
  static let creatorEyewearSpecialGreentopframe = ImageAsset(name: "creator_eyewear_special_greentopframe")
  static let creatorEyewearSpecialPinktopframe = ImageAsset(name: "creator_eyewear_special_pinktopframe")
  static let creatorEyewearSpecialRedtopframe = ImageAsset(name: "creator_eyewear_special_redtopframe")
  static let creatorEyewearSpecialWhitetopframe = ImageAsset(name: "creator_eyewear_special_whitetopframe")
  static let creatorEyewearSpecialYellowtopframe = ImageAsset(name: "creator_eyewear_special_yellowtopframe")
  static let creatorHairBangs1Black = ImageAsset(name: "creator_hair_bangs_1_black")
  static let creatorHairBangs1Blond = ImageAsset(name: "creator_hair_bangs_1_blond")
  static let creatorHairBangs1Brown = ImageAsset(name: "creator_hair_bangs_1_brown")
  static let creatorHairBangs1Red = ImageAsset(name: "creator_hair_bangs_1_red")
  static let creatorHairBangs1White = ImageAsset(name: "creator_hair_bangs_1_white")
  static let creatorHairBangs2Black = ImageAsset(name: "creator_hair_bangs_2_black")
  static let creatorHairBangs2Blond = ImageAsset(name: "creator_hair_bangs_2_blond")
  static let creatorHairBangs2Brown = ImageAsset(name: "creator_hair_bangs_2_brown")
  static let creatorHairBangs2Red = ImageAsset(name: "creator_hair_bangs_2_red")
  static let creatorHairBangs2White = ImageAsset(name: "creator_hair_bangs_2_white")
  static let creatorHairBangs3Black = ImageAsset(name: "creator_hair_bangs_3_black")
  static let creatorHairBangs3Blond = ImageAsset(name: "creator_hair_bangs_3_blond")
  static let creatorHairBangs3Brown = ImageAsset(name: "creator_hair_bangs_3_brown")
  static let creatorHairBangs3Red = ImageAsset(name: "creator_hair_bangs_3_red")
  static let creatorHairBangs3White = ImageAsset(name: "creator_hair_bangs_3_white")
  static let creatorHairBase1Black = ImageAsset(name: "creator_hair_base_1_black")
  static let creatorHairBase1Blond = ImageAsset(name: "creator_hair_base_1_blond")
  static let creatorHairBase1Brown = ImageAsset(name: "creator_hair_base_1_brown")
  static let creatorHairBase1Red = ImageAsset(name: "creator_hair_base_1_red")
  static let creatorHairBase1White = ImageAsset(name: "creator_hair_base_1_white")
  static let creatorHairBase3Black = ImageAsset(name: "creator_hair_base_3_black")
  static let creatorHairBase3Blond = ImageAsset(name: "creator_hair_base_3_blond")
  static let creatorHairBase3Brown = ImageAsset(name: "creator_hair_base_3_brown")
  static let creatorHairBase3Red = ImageAsset(name: "creator_hair_base_3_red")
  static let creatorHairBase3White = ImageAsset(name: "creator_hair_base_3_white")
  static let creatorHairFlower1 = ImageAsset(name: "creator_hair_flower_1")
  static let creatorHairFlower2 = ImageAsset(name: "creator_hair_flower_2")
  static let creatorHairFlower3 = ImageAsset(name: "creator_hair_flower_3")
  static let creatorHairFlower4 = ImageAsset(name: "creator_hair_flower_4")
  static let creatorHairFlower5 = ImageAsset(name: "creator_hair_flower_5")
  static let creatorHairFlower6 = ImageAsset(name: "creator_hair_flower_6")
  static let creatorHillsBg = ImageAsset(name: "creator_hills_bg")
  static let creatorInactivePixelArrowLeft = ImageAsset(name: "creator_inactive_pixel_arrow_left")
  static let creatorInactivePixelArrowRight = ImageAsset(name: "creator_inactive_pixel_arrow_right")
  static let creatorPurpleBg = ImageAsset(name: "creator_purple_bg")
  static let creatorSlimShirtBlack = ImageAsset(name: "creator_slim_shirt_black")
  static let creatorSlimShirtBlue = ImageAsset(name: "creator_slim_shirt_blue")
  static let creatorSlimShirtGreen = ImageAsset(name: "creator_slim_shirt_green")
  static let creatorSlimShirtPink = ImageAsset(name: "creator_slim_shirt_pink")
  static let creatorSlimShirtWhite = ImageAsset(name: "creator_slim_shirt_white")
  static let creatorSlimShirtYellow = ImageAsset(name: "creator_slim_shirt_yellow")
  static let crown = ImageAsset(name: "crown")
  static let downIcon = ImageAsset(name: "down_icon")
  static let filters = ImageAsset(name: "filters")
  static let gryphon = ImageAsset(name: "gryphon")
  static let icChevronRightWhite = ImageAsset(name: "ic_chevron_right_white")
  static let iconHelp = ImageAsset(name: "icon_help")
  static let iconInventory = ImageAsset(name: "icon_inventory")
  static let iconLock = ImageAsset(name: "icon_lock")
  static let iconRage = ImageAsset(name: "icon_rage")
  static let iconSocial = ImageAsset(name: "icon_social")
  static let indicatorDiamondSelected = ImageAsset(name: "indicatorDiamondSelected")
  static let indicatorDiamondUnselected = ImageAsset(name: "indicatorDiamondUnselected")
  static let itemPinned = ImageAsset(name: "item_pinned")
  static let justin = ImageAsset(name: "justin")
  static let justinAlt = ImageAsset(name: "justin_alt")
  static let justinTextbox = ImageAsset(name: "justin_textbox")
  static let launchBg = ImageAsset(name: "launch_bg")
  static let launchLogo = ImageAsset(name: "launch_logo")
  static let loginEmail = ImageAsset(name: "login_email")
  static let loginPassword = ImageAsset(name: "login_password")
  static let loginUsername = ImageAsset(name: "login_username")
  static let logoText = ImageAsset(name: "logo_text")
  static let messages = ImageAsset(name: "messages")
  static let minus = ImageAsset(name: "minus")
  static let minusGray = ImageAsset(name: "minus_gray")
  static let participantsDetails = ImageAsset(name: "participants_details")
  static let participantsList = ImageAsset(name: "participants_list")
  static let pillGryphon = ImageAsset(name: "pillGryphon")
  static let plus = ImageAsset(name: "plus")
  static let plusGray = ImageAsset(name: "plus_gray")
  static let rageStrikeActive = ImageAsset(name: "rage_strike_active")
  static let rageStrikePending = ImageAsset(name: "rage_strike_pending")
  static let reminder = ImageAsset(name: "reminder")
  static let seedsPromo = ImageAsset(name: "seeds_promo")
  static let shopEmptyHourglass = ImageAsset(name: "shop_empty_hourglass")
  static let shopEmptySeasonal = ImageAsset(name: "shop_empty_seasonal")
  static let speechBubble = ImageAsset(name: "speech_bubble")
  static let speechbubbleCaret = ImageAsset(name: "speechbubble_caret")
  static let star = ImageAsset(name: "star")
  static let streak = ImageAsset(name: "streak")
  static let streakAchievement = ImageAsset(name: "streak_achievement")
  static let summerCoralBackground = ImageAsset(name: "summer_coral_background")
  static let summerIanScene = ImageAsset(name: "summer_ian_scene")
  static let supportArt = ImageAsset(name: "support_art")
  static let tabbarDailies = ImageAsset(name: "tabbar_dailies")
  static let tabbarHabits = ImageAsset(name: "tabbar_habits")
  static let tabbarMenu = ImageAsset(name: "tabbar_menu")
  static let tabbarRewards = ImageAsset(name: "tabbar_rewards")
  static let tabbarTodos = ImageAsset(name: "tabbar_todos")
  static let tag = ImageAsset(name: "tag")
  static let taskLockDark = ImageAsset(name: "task_lock_dark")
  static let taskLockDisabled = ImageAsset(name: "task_lock_disabled")
  static let taskLockLight = ImageAsset(name: "task_lock_light")

  // swiftlint:disable trailing_comma
  static let allColors: [ColorAsset] = [
  ]
  static let allImages: [ImageAsset] = [
    _21Gems,
    _42Gems,
    _4Gems,
    _84Gems,
    bossContainer,
    challengeGemIcon,
    chatCopy,
    chatDelete,
    chatReply,
    chatReport,
    close,
    cloud1,
    cloud2,
    diamondButton,
    gem,
    introPage1,
    introPage2,
    introPage3,
    introTitle,
    loginBackground,
    loginBeginButton,
    loginButton,
    loginLogo,
    logo,
    memberCountIcon,
    menuMessages,
    menuSettings,
    nameplate,
    welcomeDiamond,
    bigGem,
    calendar,
    carretDown,
    carretUp,
    categoryBody,
    categoryExtras,
    categoryHair,
    categorySelectionCaret,
    categorySkin,
    challenge,
    checkboxChecked,
    checkboxUnchecked,
    checkmarkSmall,
    circleSelected,
    circleUnselected,
    creatorActivePixelArrowLeft,
    creatorActivePixelArrowRight,
    creatorBlankFace,
    creatorBroadShirtBlack,
    creatorBroadShirtBlue,
    creatorBroadShirtGreen,
    creatorBroadShirtPink,
    creatorBroadShirtWhite,
    creatorBroadShirtYellow,
    creatorChairBlack,
    creatorChairBlue,
    creatorChairGreen,
    creatorChairPink,
    creatorChairRed,
    creatorChairYellow,
    creatorEyewearSpecialBlacktopframe,
    creatorEyewearSpecialBluetopframe,
    creatorEyewearSpecialGreentopframe,
    creatorEyewearSpecialPinktopframe,
    creatorEyewearSpecialRedtopframe,
    creatorEyewearSpecialWhitetopframe,
    creatorEyewearSpecialYellowtopframe,
    creatorHairBangs1Black,
    creatorHairBangs1Blond,
    creatorHairBangs1Brown,
    creatorHairBangs1Red,
    creatorHairBangs1White,
    creatorHairBangs2Black,
    creatorHairBangs2Blond,
    creatorHairBangs2Brown,
    creatorHairBangs2Red,
    creatorHairBangs2White,
    creatorHairBangs3Black,
    creatorHairBangs3Blond,
    creatorHairBangs3Brown,
    creatorHairBangs3Red,
    creatorHairBangs3White,
    creatorHairBase1Black,
    creatorHairBase1Blond,
    creatorHairBase1Brown,
    creatorHairBase1Red,
    creatorHairBase1White,
    creatorHairBase3Black,
    creatorHairBase3Blond,
    creatorHairBase3Brown,
    creatorHairBase3Red,
    creatorHairBase3White,
    creatorHairFlower1,
    creatorHairFlower2,
    creatorHairFlower3,
    creatorHairFlower4,
    creatorHairFlower5,
    creatorHairFlower6,
    creatorHillsBg,
    creatorInactivePixelArrowLeft,
    creatorInactivePixelArrowRight,
    creatorPurpleBg,
    creatorSlimShirtBlack,
    creatorSlimShirtBlue,
    creatorSlimShirtGreen,
    creatorSlimShirtPink,
    creatorSlimShirtWhite,
    creatorSlimShirtYellow,
    crown,
    downIcon,
    filters,
    gryphon,
    icChevronRightWhite,
    iconHelp,
    iconInventory,
    iconLock,
    iconRage,
    iconSocial,
    indicatorDiamondSelected,
    indicatorDiamondUnselected,
    itemPinned,
    justin,
    justinAlt,
    justinTextbox,
    launchBg,
    launchLogo,
    loginEmail,
    loginPassword,
    loginUsername,
    logoText,
    messages,
    minus,
    minusGray,
    participantsDetails,
    participantsList,
    pillGryphon,
    plus,
    plusGray,
    rageStrikeActive,
    rageStrikePending,
    reminder,
    seedsPromo,
    shopEmptyHourglass,
    shopEmptySeasonal,
    speechBubble,
    speechbubbleCaret,
    star,
    streak,
    streakAchievement,
    summerCoralBackground,
    summerIanScene,
    supportArt,
    tabbarDailies,
    tabbarHabits,
    tabbarMenu,
    tabbarRewards,
    tabbarTodos,
    tag,
    taskLockDark,
    taskLockDisabled,
    taskLockLight,
  ]
  // swiftlint:enable trailing_comma
  @available(*, deprecated, renamed: "allImages")
  static let allValues: [AssetType] = allImages
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

extension Image {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
