// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
public enum L10n {
  /// Update bundle if you need to change app language
  static var bundle: Bundle?

  /// Abort
  public static var abort: String { return L10n.tr("Mainstrings", "abort") }
  /// About
  public static var aboutText: String { return L10n.tr("Mainstrings", "aboutText") }
  /// Accept
  public static var accept: String { return L10n.tr("Mainstrings", "accept") }
  /// Active
  public static var active: String { return L10n.tr("Mainstrings", "active") }
  /// Active on %@
  public static func activeOn(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "active_on", p1)
  }
  /// I agree to follow the guidelines
  public static var agreeGuidelinesPrompt: String { return L10n.tr("Mainstrings", "agree_guidelines_prompt") }
  /// All
  public static var all: String { return L10n.tr("Mainstrings", "all") }
  /// Allocated
  public static var allocated: String { return L10n.tr("Mainstrings", "allocated") }
  /// Animal Ears
  public static var animalEars: String { return L10n.tr("Mainstrings", "animal_ears") }
  /// API Key
  public static var apiKey: String { return L10n.tr("Mainstrings", "api_key") }
  /// Back
  public static var back: String { return L10n.tr("Mainstrings", "back") }
  /// Bangs
  public static var bangs: String { return L10n.tr("Mainstrings", "bangs") }
  /// Body Size
  public static var bodySize: String { return L10n.tr("Mainstrings", "body_size") }
  /// Broad
  public static var broad: String { return L10n.tr("Mainstrings", "broad") }
  /// Buffs
  public static var buffs: String { return L10n.tr("Mainstrings", "buffs") }
  /// buy
  public static var buy: String { return L10n.tr("Mainstrings", "buy") }
  /// Buy All
  public static var buyAll: String { return L10n.tr("Mainstrings", "buy_all") }
  /// Buy for %@
  public static func buyForX(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "buy_for_x", p1)
  }
  /// You bought '%@' for %f gold
  public static func buyReward(_ p1: String, _ p2: Float) -> String {
    return L10n.tr("Mainstrings", "buy_reward", p1, p2)
  }
  /// Cancel
  public static var cancel: String { return L10n.tr("Mainstrings", "cancel") }
  /// Change
  public static var change: String { return L10n.tr("Mainstrings", "change") }
  /// Character Level
  public static var characterLevel: String { return L10n.tr("Mainstrings", "character_level") }
  /// Chat
  public static var chat: String { return L10n.tr("Mainstrings", "chat") }
  /// Check off any Dailies you did yesterday:
  public static var checkinYesterdaysDalies: String { return L10n.tr("Mainstrings", "checkin_yesterdays_dalies") }
  /// Choose Task
  public static var chooseTask: String { return L10n.tr("Mainstrings", "choose_task") }
  /// Clear
  public static var clear: String { return L10n.tr("Mainstrings", "clear") }
  /// Close
  public static var close: String { return L10n.tr("Mainstrings", "close") }
  /// Collect
  public static var collect: String { return L10n.tr("Mainstrings", "collect") }
  /// Color
  public static var color: String { return L10n.tr("Mainstrings", "color") }
  /// Complete
  public static var complete: String { return L10n.tr("Mainstrings", "complete") }
  /// Confirm
  public static var confirm: String { return L10n.tr("Mainstrings", "confirm") }
  /// Confirm Username
  public static var confirmUsername: String { return L10n.tr("Mainstrings", "confirm_username") }
  /// Continue
  public static var `continue`: String { return L10n.tr("Mainstrings", "continue") }
  /// Controls
  public static var controls: String { return L10n.tr("Mainstrings", "controls") }
  /// Copied Message
  public static var copiedMessage: String { return L10n.tr("Mainstrings", "copied_message") }
  /// Copied to Clipboard
  public static var copiedToClipboard: String { return L10n.tr("Mainstrings", "copied_to_clipboard") }
  /// Create
  public static var create: String { return L10n.tr("Mainstrings", "create") }
  /// Create Tag
  public static var createTag: String { return L10n.tr("Mainstrings", "create_tag") }
  /// Daily
  public static var daily: String { return L10n.tr("Mainstrings", "daily") }
  /// Damage Paused
  public static var damagePaused: String { return L10n.tr("Mainstrings", "damage_paused") }
  /// Dated
  public static var dated: String { return L10n.tr("Mainstrings", "dated") }
  /// 21-Day Streaks
  public static var dayStreaks: String { return L10n.tr("Mainstrings", "day_streaks") }
  /// days
  public static var days: String { return L10n.tr("Mainstrings", "days") }
  /// Delete
  public static var delete: String { return L10n.tr("Mainstrings", "delete") }
  /// Delete Tasks
  public static var deleteTasks: String { return L10n.tr("Mainstrings", "delete_tasks") }
  /// Description
  public static var description: String { return L10n.tr("Mainstrings", "description") }
  /// Details
  public static var details: String { return L10n.tr("Mainstrings", "details") }
  /// Difficulty
  public static var difficulty: String { return L10n.tr("Mainstrings", "difficulty") }
  /// Discover
  public static var discover: String { return L10n.tr("Mainstrings", "discover") }
  /// Display name
  public static var displayName: String { return L10n.tr("Mainstrings", "display_name") }
  /// Done
  public static var done: String { return L10n.tr("Mainstrings", "done") }
  /// Due
  public static var due: String { return L10n.tr("Mainstrings", "due") }
  /// I earned a new achievement in Habitica! 
  public static var earnedAchievementShare: String { return L10n.tr("Mainstrings", "earned_achievement_share") }
  /// Edit
  public static var edit: String { return L10n.tr("Mainstrings", "edit") }
  /// Edit Tag
  public static var editTag: String { return L10n.tr("Mainstrings", "edit_tag") }
  /// Eggs
  public static var eggs: String { return L10n.tr("Mainstrings", "eggs") }
  /// Email
  public static var email: String { return L10n.tr("Mainstrings", "email") }
  /// End Challenge
  public static var endChallenge: String { return L10n.tr("Mainstrings", "end_challenge") }
  /// Equip
  public static var equip: String { return L10n.tr("Mainstrings", "equip") }
  /// Experience
  public static var experience: String { return L10n.tr("Mainstrings", "experience") }
  /// Filter
  public static var filter: String { return L10n.tr("Mainstrings", "filter") }
  /// Filter by Tags
  public static var filterByTags: String { return L10n.tr("Mainstrings", "filter_by_tags") }
  /// Finish
  public static var finish: String { return L10n.tr("Mainstrings", "finish") }
  /// Flower
  public static var flower: String { return L10n.tr("Mainstrings", "flower") }
  /// Food
  public static var food: String { return L10n.tr("Mainstrings", "food") }
  /// Force Start
  public static var forceStart: String { return L10n.tr("Mainstrings", "force_start") }
  /// Friday
  public static var friday: String { return L10n.tr("Mainstrings", "friday") }
  /// Gems allow you to buy fun extras for your account, including:
  public static var gemBenefitsTitle: String { return L10n.tr("Mainstrings", "gem_benefits_title") }
  /// %d Gem cap
  public static func gemCap(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "gem_cap", p1)
  }
  /// Gems
  public static var gems: String { return L10n.tr("Mainstrings", "gems") }
  /// Buying gems supports the developers\nand helps keep Habitica running
  public static var gemsSupportDevelopers: String { return L10n.tr("Mainstrings", "gems_support_developers") }
  /// You sent %@ a %@-month Habitica subscription.
  public static func giftConfirmationBody(_ p1: String, _ p2: String) -> String {
    return L10n.tr("Mainstrings", "gift_confirmation_body", p1, p2)
  }
  /// You sent %@ a %@-month Habitica subscription and the same subscription was applied to your account for our Gift One Get One promotion!
  public static func giftConfirmationBodyG1g1(_ p1: String, _ p2: String) -> String {
    return L10n.tr("Mainstrings", "gift_confirmation_body_g1g1", p1, p2)
  }
  /// Your gift was sent!
  public static var giftConfirmationTitle: String { return L10n.tr("Mainstrings", "gift_confirmation_title") }
  /// While this promotion is active, you’ll receive a matching subscription automatically after sending your gift.
  public static var giftOneGetOneDescription: String { return L10n.tr("Mainstrings", "gift_one_get_one_description") }
  /// Gift one, Get one!
  public static var giftOneGetOneTitle: String { return L10n.tr("Mainstrings", "gift_one_get_one_title") }
  /// Enter recipient's @ username
  public static var giftRecipientSubtitle: String { return L10n.tr("Mainstrings", "gift_recipient_subtitle") }
  /// Who would you like to gift to?
  public static var giftRecipientTitle: String { return L10n.tr("Mainstrings", "gift_recipient_title") }
  /// Choose the subscription you’d like to gift below! This purchase won’t automatically renew.
  public static var giftSubscriptionPrompt: String { return L10n.tr("Mainstrings", "gift_subscription_prompt") }
  /// Glasses
  public static var glasses: String { return L10n.tr("Mainstrings", "glasses") }
  /// Gold
  public static var gold: String { return L10n.tr("Mainstrings", "gold") }
  /// Great
  public static var great: String { return L10n.tr("Mainstrings", "great") }
  /// Grey
  public static var grey: String { return L10n.tr("Mainstrings", "grey") }
  /// Group By
  public static var groupBy: String { return L10n.tr("Mainstrings", "group_by") }
  /// Hatch egg
  public static var hatchEgg: String { return L10n.tr("Mainstrings", "hatch_egg") }
  /// Hatch with potion
  public static var hatchPotion: String { return L10n.tr("Mainstrings", "hatch_potion") }
  /// Hatching Potions
  public static var hatchingPotions: String { return L10n.tr("Mainstrings", "hatching_potions") }
  /// Headband
  public static var headband: String { return L10n.tr("Mainstrings", "headband") }
  /// Health
  public static var health: String { return L10n.tr("Mainstrings", "health") }
  /// +%d Mystic Hourglass
  public static func hourglassCount(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "hourglass_count", p1)
  }
  /// Inactive
  public static var inactive: String { return L10n.tr("Mainstrings", "inactive") }
  /// You have to specify a valid Habitica Username as recipient.
  public static var invalidRecipientMessage: String { return L10n.tr("Mainstrings", "invalid_recipient_message") }
  /// Invalid Habitica Username
  public static var invalidRecipientTitle: String { return L10n.tr("Mainstrings", "invalid_recipient_title") }
  /// Invitations
  public static var invitations: String { return L10n.tr("Mainstrings", "invitations") }
  /// Invite Party
  public static var inviteParty: String { return L10n.tr("Mainstrings", "invite_party") }
  /// Join
  public static var join: String { return L10n.tr("Mainstrings", "join") }
  /// Join Challenge
  public static var joinChallenge: String { return L10n.tr("Mainstrings", "join_challenge") }
  /// Keep Tasks
  public static var keepTasks: String { return L10n.tr("Mainstrings", "keep_tasks") }
  /// Last Activity %@
  public static func lastActivity(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "last_activity", p1)
  }
  /// Leader
  public static var leader: String { return L10n.tr("Mainstrings", "leader") }
  /// Leave
  public static var leave: String { return L10n.tr("Mainstrings", "leave") }
  /// Leave Challenge
  public static var leaveChallenge: String { return L10n.tr("Mainstrings", "leave_challenge") }
  /// Do you want to leave the challenge and keep or delete the tasks?
  public static var leaveChallengePrompt: String { return L10n.tr("Mainstrings", "leave_challenge_prompt") }
  /// Leave Challenge?
  public static var leaveChallengeTitle: String { return L10n.tr("Mainstrings", "leave_challenge_title") }
  /// Level
  public static var level: String { return L10n.tr("Mainstrings", "level") }
  /// Level %d
  public static func levelNumber(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "level_number", p1)
  }
  /// By accomplishing your real-life goals, you've grown to Level %ld!
  public static func levelupDescription(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "levelup_description", p1)
  }
  /// I got to level %ld in Habitica by improving my real-life habits!
  public static func levelupShare(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "levelup_share", p1)
  }
  /// You gained a level!
  public static var levelupTitle: String { return L10n.tr("Mainstrings", "levelup_title") }
  /// Mana
  public static var mana: String { return L10n.tr("Mainstrings", "mana") }
  /// Mana Points
  public static var manaPoints: String { return L10n.tr("Mainstrings", "mana_points") }
  /// Menu
  public static var menu: String { return L10n.tr("Mainstrings", "menu") }
  /// Moderator
  public static var moderator: String { return L10n.tr("Mainstrings", "moderator") }
  /// Monday
  public static var monday: String { return L10n.tr("Mainstrings", "monday") }
  /// Monthly
  public static var monthly: String { return L10n.tr("Mainstrings", "monthly") }
  /// Monthly Gem Cap Reached
  public static var monthlyGemCapReached: String { return L10n.tr("Mainstrings", "monthly_gem_cap_reached") }
  /// months
  public static var months: String { return L10n.tr("Mainstrings", "months") }
  /// Mounts
  public static var mounts: String { return L10n.tr("Mainstrings", "mounts") }
  /// My Challenges
  public static var myChallenges: String { return L10n.tr("Mainstrings", "my_challenges") }
  /// My Guilds
  public static var myGuilds: String { return L10n.tr("Mainstrings", "my_guilds") }
  /// Mystery Sets
  public static var mysterySets: String { return L10n.tr("Mainstrings", "mystery_sets") }
  /// Name
  public static var name: String { return L10n.tr("Mainstrings", "name") }
  /// Never
  public static var never: String { return L10n.tr("Mainstrings", "never") }
  /// never
  public static var neverLowerCase: String { return L10n.tr("Mainstrings", "never_lower_case") }
  /// Next
  public static var next: String { return L10n.tr("Mainstrings", "next") }
  /// Your next prize unlocks in 1 Check-In.
  public static var nextCheckinPrize1Day: String { return L10n.tr("Mainstrings", "next_checkin_prize_1_day") }
  /// Your next prize unlocks in %d Check-Ins
  public static func nextCheckinPrizeXDays(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "next_checkin_prize_x_days", p1)
  }
  /// No Benefit
  public static var noBenefit: String { return L10n.tr("Mainstrings", "no_benefit") }
  /// No Camera available
  public static var noCamera: String { return L10n.tr("Mainstrings", "no_camera") }
  /// no days
  public static var noDays: String { return L10n.tr("Mainstrings", "no_days") }
  /// Not enough Gems
  public static var notEnoughGems: String { return L10n.tr("Mainstrings", "not_enough_gems") }
  /// Not enough Gold
  public static var notEnoughGold: String { return L10n.tr("Mainstrings", "not_enough_gold") }
  /// Not enough Hourglasses
  public static var notEnoughHourglasses: String { return L10n.tr("Mainstrings", "not_enough_hourglasses") }
  /// Not getting the right drops? Check out the Market to buy just the things you need!
  public static var notGettingDrops: String { return L10n.tr("Mainstrings", "not_getting_drops") }
  /// Notes
  public static var notes: String { return L10n.tr("Mainstrings", "notes") }
  /// OK
  public static var ok: String { return L10n.tr("Mainstrings", "ok") }
  /// 1 Filter
  public static var oneFilter: String { return L10n.tr("Mainstrings", "one_filter") }
  /// 1 Month
  public static var oneMonth: String { return L10n.tr("Mainstrings", "one_month") }
  /// Open
  public static var `open`: String { return L10n.tr("Mainstrings", "open") }
  /// Open App Store Page
  public static var openAppStore: String { return L10n.tr("Mainstrings", "open_app_store") }
  /// Open iTunes
  public static var openItunes: String { return L10n.tr("Mainstrings", "open_itunes") }
  /// Open Habitica Website
  public static var openWebsite: String { return L10n.tr("Mainstrings", "open_website") }
  /// Password
  public static var password: String { return L10n.tr("Mainstrings", "password") }
  /// Pause Damage
  public static var pauseDamage: String { return L10n.tr("Mainstrings", "pause_damage") }
  /// Pending damage
  public static var pendingDamage: String { return L10n.tr("Mainstrings", "pending_damage") }
  /// Pets
  public static var pets: String { return L10n.tr("Mainstrings", "pets") }
  /// Photo URL
  public static var photoUrl: String { return L10n.tr("Mainstrings", "photo_url") }
  /// Pin to Rewards
  public static var pinToRewards: String { return L10n.tr("Mainstrings", "pin_to_rewards") }
  /// Plain Backgrounds
  public static var plainBackgrounds: String { return L10n.tr("Mainstrings", "plain_backgrounds") }
  /// Ponytail
  public static var ponytail: String { return L10n.tr("Mainstrings", "ponytail") }
  /// Publish Challenge
  public static var publishChallenge: String { return L10n.tr("Mainstrings", "publish_challenge") }
  /// Purchase for %d Gems
  public static func purchaseForGems(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "purchase_for_gems", p1)
  }
  /// Purchase Gems
  public static var purchaseGems: String { return L10n.tr("Mainstrings", "purchase_gems") }
  /// You purchased %@
  public static func purchased(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "purchased", p1)
  }
  /// The scanned QR-Code did not contain a valid Habitica User ID.
  public static var qrInvalidIdMessage: String { return L10n.tr("Mainstrings", "qr_invalid_id_message") }
  /// Invalid Habitica User ID
  public static var qrInvalidIdTitle: String { return L10n.tr("Mainstrings", "qr_invalid_id_title") }
  /// Quests
  public static var quests: String { return L10n.tr("Mainstrings", "quests") }
  /// Rage Meter
  public static var rageMeter: String { return L10n.tr("Mainstrings", "rage_meter") }
  /// Randomize
  public static var randomize: String { return L10n.tr("Mainstrings", "randomize") }
  /// You open the box and receive %@
  public static func receivedMysteryItem(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "received_mystery_item", p1)
  }
  /// Recipient
  public static var recipient: String { return L10n.tr("Mainstrings", "recipient") }
  /// Reject
  public static var reject: String { return L10n.tr("Mainstrings", "reject") }
  /// Remember to check off your Dailies!
  public static var rememberCheckOffDailies: String { return L10n.tr("Mainstrings", "remember_check_off_dailies") }
  /// Reminder
  public static var reminder: String { return L10n.tr("Mainstrings", "reminder") }
  /// Repeat Password
  public static var repeatPassword: String { return L10n.tr("Mainstrings", "repeat_password") }
  /// Reply
  public static var reply: String { return L10n.tr("Mainstrings", "reply") }
  /// Report %@ for violation?
  public static func reportXViolation(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "report_x_violation", p1)
  }
  /// Reset Justins Tips
  public static var resetTips: String { return L10n.tr("Mainstrings", "reset_tips") }
  /// Reset Streak
  public static var resetStreak: String { return L10n.tr("Mainstrings", "resetStreak") }
  /// Resume Damage
  public static var resumeDamage: String { return L10n.tr("Mainstrings", "resume_damage") }
  /// Resync
  public static var resync: String { return L10n.tr("Mainstrings", "resync") }
  /// Resync all
  public static var resyncAll: String { return L10n.tr("Mainstrings", "resync_all") }
  /// Resync this task
  public static var resyncTask: String { return L10n.tr("Mainstrings", "resync_task") }
  /// Saturday
  public static var saturday: String { return L10n.tr("Mainstrings", "saturday") }
  /// Save
  public static var save: String { return L10n.tr("Mainstrings", "save") }
  /// Scan QR Code
  public static var scanQRCode: String { return L10n.tr("Mainstrings", "scan_QR_code") }
  /// Search
  public static var search: String { return L10n.tr("Mainstrings", "search") }
  /// Sell for %d gold
  public static func sell(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "sell", p1)
  }
  /// Send
  public static var send: String { return L10n.tr("Mainstrings", "send") }
  /// Send Gift
  public static var sendGift: String { return L10n.tr("Mainstrings", "send_gift") }
  /// Share
  public static var share: String { return L10n.tr("Mainstrings", "share") }
  /// Shirt
  public static var shirt: String { return L10n.tr("Mainstrings", "shirt") }
  /// Size
  public static var size: String { return L10n.tr("Mainstrings", "size") }
  /// Skip
  public static var skip: String { return L10n.tr("Mainstrings", "skip") }
  /// Slim
  public static var slim: String { return L10n.tr("Mainstrings", "slim") }
  /// Special Items
  public static var specialItems: String { return L10n.tr("Mainstrings", "specialItems") }
  /// Staff
  public static var staff: String { return L10n.tr("Mainstrings", "staff") }
  /// Start my day
  public static var startMyDay: String { return L10n.tr("Mainstrings", "start_my_day") }
  /// You've completed your Daily for 21 days in a row! Amazing job. Don't break the streak!
  public static var streakAchievementDescription: String { return L10n.tr("Mainstrings", "streak_achievement_description") }
  /// You earned a streak achievement!
  public static var streakAchievementTitle: String { return L10n.tr("Mainstrings", "streak_achievement_title") }
  /// Strong
  public static var strong: String { return L10n.tr("Mainstrings", "strong") }
  /// Subscribe
  public static var subscribe: String { return L10n.tr("Mainstrings", "subscribe") }
  /// Subscribe for Hourglasses
  public static var subscribeForHourglasses: String { return L10n.tr("Mainstrings", "subscribe_for_hourglasses") }
  /// Subscription
  public static var subscription: String { return L10n.tr("Mainstrings", "subscription") }
  /// Become a subscriber and you’ll get these useful benefits:
  public static var subscriptionBenefitsTitle: String { return L10n.tr("Mainstrings", "subscription_benefits_title") }
  /// Gift a Subscription
  public static var subscriptionGiftButton: String { return L10n.tr("Mainstrings", "subscription_gift_button") }
  /// Want to give the benefits of a subscription to someone else?
  public static var subscriptionGiftExplanation: String { return L10n.tr("Mainstrings", "subscription_gift_explanation") }
  /// Alexander the Merchant will sell you Gems at a cost of 20 gold per gem. His monthly shipments are initially capped at 25 Gems per month, but this cap increases by 5 Gems for every three months of consecutive subscription, up to a maximum of 50 Gems per month!
  public static var subscriptionInfo1Description: String { return L10n.tr("Mainstrings", "subscription_info_1_description") }
  /// Buy gems with gold
  public static var subscriptionInfo1Title: String { return L10n.tr("Mainstrings", "subscription_info_1_title") }
  /// Each month you will receive a unique cosmetic item for your avatar!\n\nPlus, for every three months of consecutive subscription, the Mysterious Time Travelers will grant you access to historic (and futuristic!) cosmetic items.
  public static var subscriptionInfo2Description: String { return L10n.tr("Mainstrings", "subscription_info_2_description") }
  /// Exclusive monthly items
  public static var subscriptionInfo2Title: String { return L10n.tr("Mainstrings", "subscription_info_2_title") }
  /// Makes completed To-Dos and task history available for longer.
  public static var subscriptionInfo3Description: String { return L10n.tr("Mainstrings", "subscription_info_3_description") }
  /// Retain additional history entries
  public static var subscriptionInfo3Title: String { return L10n.tr("Mainstrings", "subscription_info_3_title") }
  /// Double drop caps will let you receive more items from your completed tasks every day, helping you complete your stable faster!
  public static var subscriptionInfo4Description: String { return L10n.tr("Mainstrings", "subscription_info_4_description") }
  /// Daily drop-caps doubled
  public static var subscriptionInfo4Title: String { return L10n.tr("Mainstrings", "subscription_info_4_title") }
  /// Subscribing supports the developers\nand helps keep Habitica running
  public static var subscriptionSupportDevelopers: String { return L10n.tr("Mainstrings", "subscription_support_developers") }
  /// success
  public static var success: String { return L10n.tr("Mainstrings", "success") }
  /// Summary
  public static var summary: String { return L10n.tr("Mainstrings", "summary") }
  /// Sunday
  public static var sunday: String { return L10n.tr("Mainstrings", "sunday") }
  /// Tags
  public static var tags: String { return L10n.tr("Mainstrings", "tags") }
  /// Take me back
  public static var takeMeBack: String { return L10n.tr("Mainstrings", "take_me_back") }
  /// Tap to Show
  public static var tapToShow: String { return L10n.tr("Mainstrings", "tap_to_show") }
  /// Welcome to the Inn! Pull up a chair to chat, or take a break from your tasks.
  public static var tavernIntroHeader: String { return L10n.tr("Mainstrings", "tavern_intro_header") }
  /// Teleporting to Habitica
  public static var teleportingHabitica: String { return L10n.tr("Mainstrings", "teleporting_habitica") }
  /// Thursday
  public static var thursday: String { return L10n.tr("Mainstrings", "thursday") }
  /// Title
  public static var title: String { return L10n.tr("Mainstrings", "title") }
  /// Tuesday
  public static var tuesday: String { return L10n.tr("Mainstrings", "tuesday") }
  /// Two-Handed
  public static var twoHanded: String { return L10n.tr("Mainstrings", "twoHanded") }
  /// Unequip
  public static var unequip: String { return L10n.tr("Mainstrings", "unequip") }
  /// You've unlocked the Drop System! Now when you complete tasks, you have a small chance of finding an item, including eggs, potions, and food!
  public static var unlockDropsDescription: String { return L10n.tr("Mainstrings", "unlockDropsDescription") }
  /// You unlocked the drop system!
  public static var unlockDropsTitle: String { return L10n.tr("Mainstrings", "unlockDropsTitle") }
  /// Unlocks at level 10
  public static var unlocksLevelTen: String { return L10n.tr("Mainstrings", "unlocks_level_ten") }
  /// Unlocks after selecting a class
  public static var unlocksSelectingClass: String { return L10n.tr("Mainstrings", "unlocks_selecting_class") }
  /// Unpin from Rewards
  public static var unpinFromRewards: String { return L10n.tr("Mainstrings", "unpin_from_rewards") }
  /// No longer want to subscribe? You can manage your subscription from iTunes.
  public static var unsubscribeItunes: String { return L10n.tr("Mainstrings", "unsubscribe_itunes") }
  /// No longer want to subscribe? Due to your payment method, you can only unsubscribe through the website.
  public static var unsubscribeWebsite: String { return L10n.tr("Mainstrings", "unsubscribe_website") }
  /// Use
  public static var use: String { return L10n.tr("Mainstrings", "use") }
  /// User ID
  public static var userID: String { return L10n.tr("Mainstrings", "userID") }
  /// Username
  public static var username: String { return L10n.tr("Mainstrings", "username") }
  /// Your username was confirmed
  public static var usernameConfirmedToast: String { return L10n.tr("Mainstrings", "username_confirmed_toast") }
  /// Your display name hasn’t changed but your old login name will now be your username used for invitations, chat @mentions, and messaging.
  public static var usernamePromptBody: String { return L10n.tr("Mainstrings", "username_prompt_body") }
  /// Usernames should conform to our #<ts>Terms of Service# and #<cg>Community Guidelines#. If you didn’t previously set a login name, your username was auto-generated.
  public static var usernamePromptDisclaimer: String { return L10n.tr("Mainstrings", "username_prompt_disclaimer") }
  /// It’s time to set your username!
  public static var usernamePromptTitle: String { return L10n.tr("Mainstrings", "username_prompt_title") }
  /// If you’d like to learn more about this change, #<wk>visit our wiki.#
  public static var usernamePromptWiki: String { return L10n.tr("Mainstrings", "username_prompt_wiki") }
  /// Invitation was sent to users.
  public static var usersInvited: String { return L10n.tr("Mainstrings", "users_invited") }
  /// View Participant Progress
  public static var viewParticipantProgress: String { return L10n.tr("Mainstrings", "view_participant_progress") }
  /// Weak
  public static var `weak`: String { return L10n.tr("Mainstrings", "weak") }
  /// Wednesday
  public static var wednesday: String { return L10n.tr("Mainstrings", "wednesday") }
  /// Weekly
  public static var weekly: String { return L10n.tr("Mainstrings", "weekly") }
  /// weeks
  public static var weeks: String { return L10n.tr("Mainstrings", "weeks") }
  /// Welcome Back!
  public static var welcomeBack: String { return L10n.tr("Mainstrings", "welcome_back") }
  /// What's a World Boss?
  public static var whatsWorldBoss: String { return L10n.tr("Mainstrings", "whats_world_boss") }
  /// Wheelchair
  public static var wheelchair: String { return L10n.tr("Mainstrings", "wheelchair") }
  /// Oh dear, pay no heed to the monster below -- this is still a safe haven to chat on your breaks.
  public static var worldBossIntroHeader: String { return L10n.tr("Mainstrings", "world_boss_intro_header") }
  /// Write a Message
  public static var writeAMessage: String { return L10n.tr("Mainstrings", "write_a_message") }
  /// Write Message
  public static var writeMessage: String { return L10n.tr("Mainstrings", "write_message") }
  /// Write to %@
  public static func writeTo(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "write_to", p1)
  }
  /// %ld Filters
  public static func xFilters(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "x_filters", p1)
  }
  /// %d Months
  public static func xMonths(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "x_months", p1)
  }
  /// Yearly
  public static var yearly: String { return L10n.tr("Mainstrings", "yearly") }
  /// years
  public static var years: String { return L10n.tr("Mainstrings", "years") }
  /// Your balance:
  public static var yourBalance: String { return L10n.tr("Mainstrings", "your_balance") }

  public enum NPCs {
    /// Alex the Merchant
    public static var alex: String { return L10n.tr("Mainstrings", "NPCs.alex") }
    /// Daniel the inn keeper
    public static var daniel: String { return L10n.tr("Mainstrings", "NPCs.daniel") }
    /// Ian the Quest Guide
    public static var ian: String { return L10n.tr("Mainstrings", "NPCs.ian") }
    /// Matt the beast master
    public static var matt: String { return L10n.tr("Mainstrings", "NPCs.matt") }
    /// Seasonal Sorceress
    public static var seasonalSorceress: String { return L10n.tr("Mainstrings", "NPCs.seasonalSorceress") }
  }

  public enum About {
    /// Acknowledgements
    public static var acknowledgements: String { return L10n.tr("Mainstrings", "about.acknowledgements") }
    /// Export Database
    public static var exportDatabase: String { return L10n.tr("Mainstrings", "about.export_database") }
    /// Leave Review
    public static var leaveReview: String { return L10n.tr("Mainstrings", "about.leave_review") }
    /// Web love open source software.
    public static var loveOpenSource: String { return L10n.tr("Mainstrings", "about.love_open_source") }
    /// Update available: %@
    public static func newVersion(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "about.new_version", p1)
    }
    /// Whoops, looks like you haven't set up your email on this phone yet. Configure an account in the iOS mail app to use this quick-reporting option, or just email us directly at %@
    public static func noEmailMessage(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "about.no_email_message", p1)
    }
    /// Your email isn't set up yet
    public static var noEmailTitle: String { return L10n.tr("Mainstrings", "about.no_email_title") }
    /// Report a Bug
    public static var reportBug: String { return L10n.tr("Mainstrings", "about.report_bug") }
    /// Send Feedback
    public static var sendFeedback: String { return L10n.tr("Mainstrings", "about.send_feedback") }
    /// Version
    public static var version: String { return L10n.tr("Mainstrings", "about.version") }
    /// View Source Code
    public static var viewSourceCode: String { return L10n.tr("Mainstrings", "about.view_source_code") }
    /// Website
    public static var website: String { return L10n.tr("Mainstrings", "about.website") }
    /// See what's new
    public static var whatsNew: String { return L10n.tr("Mainstrings", "about.whats_new") }
  }

  public enum Accessibility {
    /// Collapse Checklist
    public static var collapseChecklist: String { return L10n.tr("Mainstrings", "accessibility.collapse_checklist") }
    /// Complete Task
    public static var completeTask: String { return L10n.tr("Mainstrings", "accessibility.complete_task") }
    /// Completed
    public static var completed: String { return L10n.tr("Mainstrings", "accessibility.completed") }
    /// Completed %@
    public static func completedX(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "accessibility.completed_x", p1)
    }
    /// Copy Message
    public static var copyMessage: String { return L10n.tr("Mainstrings", "accessibility.copy_message") }
    /// Delete Message
    public static var deleteMessage: String { return L10n.tr("Mainstrings", "accessibility.delete_message") }
    /// Double tap to complete
    public static var doubleTapToComplete: String { return L10n.tr("Mainstrings", "accessibility.double_tap_to_complete") }
    /// Double tap to edit
    public static var doubleTapToEdit: String { return L10n.tr("Mainstrings", "accessibility.double_tap_to_edit") }
    /// Due
    public static var due: String { return L10n.tr("Mainstrings", "accessibility.due") }
    /// Expand Checklist
    public static var expandChecklist: String { return L10n.tr("Mainstrings", "accessibility.expand_checklist") }
    /// Like Message
    public static var likeMessage: String { return L10n.tr("Mainstrings", "accessibility.like_message") }
    /// Not Completed
    public static var notCompleted: String { return L10n.tr("Mainstrings", "accessibility.not_completed") }
    /// Not Completed %@
    public static func notCompletedX(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "accessibility.not_completed_x", p1)
    }
    /// Not Due
    public static var notDue: String { return L10n.tr("Mainstrings", "accessibility.not_due") }
    /// Reply to Message
    public static var replyToMessage: String { return L10n.tr("Mainstrings", "accessibility.reply_to_message") }
    /// Report Message
    public static var reportMessage: String { return L10n.tr("Mainstrings", "accessibility.report_message") }
    /// Score Habit Down
    public static var scoreHabitDown: String { return L10n.tr("Mainstrings", "accessibility.score_habit_down") }
    /// Score Habit Up
    public static var scoreHabitUp: String { return L10n.tr("Mainstrings", "accessibility.score_habit_up") }
    /// Double tap to hide boss art
    public static var tapHideBossArt: String { return L10n.tr("Mainstrings", "accessibility.tap_hide_boss_art") }
    /// %@, World Boss, pending damage: %@
    public static func worldBossPendingDamage(_ p1: String, _ p2: String) -> String {
      return L10n.tr("Mainstrings", "accessibility.world_boss_pending_damage", p1, p2)
    }
  }

  public enum Avatar {
    /// Background
    public static var background: String { return L10n.tr("Mainstrings", "avatar.background") }
    /// Bangs
    public static var bangs: String { return L10n.tr("Mainstrings", "avatar.bangs") }
    /// Beard
    public static var beard: String { return L10n.tr("Mainstrings", "avatar.beard") }
    /// Body
    public static var body: String { return L10n.tr("Mainstrings", "avatar.body") }
    /// Extras
    public static var extras: String { return L10n.tr("Mainstrings", "avatar.extras") }
    /// Flower
    public static var flower: String { return L10n.tr("Mainstrings", "avatar.flower") }
    /// Glasses
    public static var glasses: String { return L10n.tr("Mainstrings", "avatar.glasses") }
    /// Hair
    public static var hair: String { return L10n.tr("Mainstrings", "avatar.hair") }
    /// Hair Style
    public static var hairStyle: String { return L10n.tr("Mainstrings", "avatar.hair_style") }
    /// Hair Color
    public static var hairColor: String { return L10n.tr("Mainstrings", "avatar.hairColor") }
    /// Head
    public static var head: String { return L10n.tr("Mainstrings", "avatar.head") }
    /// Mustache
    public static var mustache: String { return L10n.tr("Mainstrings", "avatar.mustache") }
    /// Shirt
    public static var shirt: String { return L10n.tr("Mainstrings", "avatar.shirt") }
    /// Skin
    public static var skin: String { return L10n.tr("Mainstrings", "avatar.skin") }
    /// Skin Color
    public static var skinColor: String { return L10n.tr("Mainstrings", "avatar.skin_color") }
    /// Wheelchair
    public static var wheelchair: String { return L10n.tr("Mainstrings", "avatar.wheelchair") }
  }

  public enum Classes {
    /// Become a %@
    public static func becomeAClass(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "classes.become_a_class", p1)
    }
    /// %@ Class
    public static func classHeader(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "classes.class_header", p1)
    }
    /// Healer
    public static var healer: String { return L10n.tr("Mainstrings", "classes.healer") }
    /// Healers stand impervious against harm, and extend that protection to others. Missed Dailies and bad Habits don't faze them much, and they have ways to recover Health from failure. Play a Healer if you enjoy assisting others in your Party, or if the idea of cheating Death through hard work inspires you!
    public static var healerDescription: String { return L10n.tr("Mainstrings", "classes.healer_description") }
    /// Mage
    public static var mage: String { return L10n.tr("Mainstrings", "classes.mage") }
    /// Mages learn swiftly, gaining Experience and Levels faster than other classes. They also get a great deal of Mana for using special abilities. Play a Mage if you enjoy the tactical game aspects of Habitica, or if you are strongly motivated by leveling up and unlocking advanced features! 
    public static var mageDescription: String { return L10n.tr("Mainstrings", "classes.mage_description") }
    /// Rogue
    public static var rogue: String { return L10n.tr("Mainstrings", "classes.rogue") }
    /// Rogues love to accumulate wealth, gaining more Gold than anyone else, and are adept at finding random items. Their iconic Stealth ability lets them duck the consequences of missed Dailies. Play a Rogue if you find strong motivation from Rewards and Achievements, striving for loot and badges!
    public static var rogueDescription: String { return L10n.tr("Mainstrings", "classes.rogue_description") }
    /// Warrior
    public static var warrior: String { return L10n.tr("Mainstrings", "classes.warrior") }
    /// Warriors score more and better "critical hits", which randomly give bonus Gold, Experience, and drop chance for scoring a task. They also deal heavy damage to boss monsters. Play a Warrior if you find motivation from unpredictable jackpot-style rewards, or want to dish out the hurt in boss Quests!
    public static var warriorDescription: String { return L10n.tr("Mainstrings", "classes.warrior_description") }
  }

  public enum Equipment {
    /// Armor
    public static var armor: String { return L10n.tr("Mainstrings", "equipment.armor") }
    /// Auto-Equip new
    public static var autoEquip: String { return L10n.tr("Mainstrings", "equipment.auto_equip") }
    /// Back Accessory
    public static var back: String { return L10n.tr("Mainstrings", "equipment.back") }
    /// Battle Gear
    public static var battleGear: String { return L10n.tr("Mainstrings", "equipment.battle_gear") }
    /// Body Accessory
    public static var body: String { return L10n.tr("Mainstrings", "equipment.body") }
    /// Class Equipment
    public static var classEquipment: String { return L10n.tr("Mainstrings", "equipment.class_equipment") }
    /// Costume
    public static var costume: String { return L10n.tr("Mainstrings", "equipment.costume") }
    /// Select "Use Costume" to equip items to your avatar without affecting the Stats from your Battle Gear! This means that you can dress up your avatar in whatever outfit you like while still having your best Battle Gear equipped.
    public static var costumeExplanation: String { return L10n.tr("Mainstrings", "equipment.costume_explanation") }
    /// Equipment
    public static var equipment: String { return L10n.tr("Mainstrings", "equipment.equipment") }
    /// Eyewear
    public static var eyewear: String { return L10n.tr("Mainstrings", "equipment.eyewear") }
    /// Head Gear
    public static var head: String { return L10n.tr("Mainstrings", "equipment.head") }
    /// Head Accessory
    public static var headAccessory: String { return L10n.tr("Mainstrings", "equipment.head_accessory") }
    /// Nothing Equipped
    public static var nothingEquipped: String { return L10n.tr("Mainstrings", "equipment.nothing_equipped") }
    /// Off-Hand
    public static var offHand: String { return L10n.tr("Mainstrings", "equipment.off_hand") }
    /// Use Costume
    public static var useCostume: String { return L10n.tr("Mainstrings", "equipment.use_costume") }
    /// Weapon
    public static var weapon: String { return L10n.tr("Mainstrings", "equipment.weapon") }
  }

  public enum Errors {
    /// Error
    public static var error: String { return L10n.tr("Mainstrings", "errors.error") }
    /// There was an error accepting the quest invitation
    public static var questInviteAccept: String { return L10n.tr("Mainstrings", "errors.quest_invite_accept") }
    /// There was an error rejecting the quest invitation
    public static var questInviteReject: String { return L10n.tr("Mainstrings", "errors.quest_invite_reject") }
    /// Your message could not be sent.
    public static var reply: String { return L10n.tr("Mainstrings", "errors.reply") }
    /// There was an error with your request: %@
    public static func request(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "errors.request", p1)
    }
    /// Sync Error
    public static var sync: String { return L10n.tr("Mainstrings", "errors.sync") }
    /// There was an error syncing some changes.
    public static var syncMessage: String { return L10n.tr("Mainstrings", "errors.sync_message") }
  }

  public enum Faint {
    /// Refill Health & Try Again
    public static var button: String { return L10n.tr("Mainstrings", "faint.button") }
    /// You lost a Level, your Gold, and a piece of Equipment, but you can get them all back with hard work!
    public static var description: String { return L10n.tr("Mainstrings", "faint.description") }
    /// Don't despair!
    public static var dontDespair: String { return L10n.tr("Mainstrings", "faint.dont_despair") }
    /// Good luck--you'll do great.
    public static var goodLuck: String { return L10n.tr("Mainstrings", "faint.good_luck") }
    /// You ran out of Health!
    public static var title: String { return L10n.tr("Mainstrings", "faint.title") }
  }

  public enum Groups {
    /// Assign new Leader
    public static var assignNewLeader: String { return L10n.tr("Mainstrings", "groups.assign_new_leader") }
    /// Name may not be empty.
    public static var errorNameRequired: String { return L10n.tr("Mainstrings", "groups.error_name_required") }
    /// %@ invited you to join Guild: %@
    public static func guildInvitationInvitername(_ p1: String, _ p2: String) -> String {
      return L10n.tr("Mainstrings", "groups.guild_invitation_invitername", p1, p2)
    }
    /// Someone invited you to join Guild: %@
    public static func guildInvitationNoInvitername(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "groups.guild_invitation_no_invitername", p1)
    }
    /// Invite a Member
    public static var inviteMember: String { return L10n.tr("Mainstrings", "groups.invite_member") }
    /// Only leader can create Challenges
    public static var leaderChallenges: String { return L10n.tr("Mainstrings", "groups.leader_challenges") }
    /// Members
    public static var members: String { return L10n.tr("Mainstrings", "groups.members") }

    public enum Invite {
      /// Add an Email
      public static var addEmail: String { return L10n.tr("Mainstrings", "groups.invite.add_email") }
      /// Add a User ID
      public static var addUserid: String { return L10n.tr("Mainstrings", "groups.invite.add_userid") }
      /// Add a Username
      public static var addUsername: String { return L10n.tr("Mainstrings", "groups.invite.add_username") }
      /// Invitation Type
      public static var invitationType: String { return L10n.tr("Mainstrings", "groups.invite.invitation_type") }
    }
  }

  public enum Guilds {
    /// Guild Bank
    public static var guildBank: String { return L10n.tr("Mainstrings", "guilds.guild_bank") }
    /// Guild Challenges
    public static var guildChallenges: String { return L10n.tr("Mainstrings", "guilds.guild_challenges") }
    /// Guild Description
    public static var guildDescription: String { return L10n.tr("Mainstrings", "guilds.guild_description") }
    /// Guild Leader
    public static var guildLeader: String { return L10n.tr("Mainstrings", "guilds.guild_leader") }
    /// Guild Members
    public static var guildMembers: String { return L10n.tr("Mainstrings", "guilds.guild_members") }
    /// Invite to Guild
    public static var inviteToGuild: String { return L10n.tr("Mainstrings", "guilds.invite_to_guild") }
    /// Join Guild
    public static var joinGuild: String { return L10n.tr("Mainstrings", "guilds.join_guild") }
    /// You joined the guild
    public static var joinedGuild: String { return L10n.tr("Mainstrings", "guilds.joined_guild") }
    /// Keep challenges
    public static var keepChallenges: String { return L10n.tr("Mainstrings", "guilds.keep_challenges") }
    /// Leave Challenges
    public static var leaveChallenges: String { return L10n.tr("Mainstrings", "guilds.leave_challenges") }
    /// Do you want to leave the guild and keep or leave the challenges?
    public static var leaveGuildDescription: String { return L10n.tr("Mainstrings", "guilds.leave_guild_description") }
    /// Leave Guild?
    public static var leaveGuildTitle: String { return L10n.tr("Mainstrings", "guilds.leave_guild_title") }
    /// You left the guild
    public static var leftGuild: String { return L10n.tr("Mainstrings", "guilds.left_guild") }
  }

  public enum Intro {
    /// So how would you like to look? Don’t worry, you can change this later.
    public static var avatarSetupSpeechbubble: String { return L10n.tr("Mainstrings", "intro.avatar_setup_speechbubble") }
    /// Let's start!
    public static var letsGo: String { return L10n.tr("Mainstrings", "intro.lets_go") }
    /// Great! Now, what are you interested in working on throughout this journey?
    public static var taskSetupSpeechbubble: String { return L10n.tr("Mainstrings", "intro.task_setup_speechbubble") }
    /// What should we call you?
    public static var welcomePrompt: String { return L10n.tr("Mainstrings", "intro.welcome_prompt") }
    /// Oh, you must be new here. I’m Justin, your guide to Habitica.\n\nFirst, what should we call you? Feel free to change what I picked. When you’re all set, let’s create your avatar!
    public static var welcomeSpeechbubble: String { return L10n.tr("Mainstrings", "intro.welcome_speechbubble") }

    public enum Card1 {
      /// It’s time to have fun while you get things done. Join over 2 million others improving their life one task at a time.
      public static var text: String { return L10n.tr("Mainstrings", "intro.card1.text") }
      /// Welcome to
      public static var title: String { return L10n.tr("Mainstrings", "intro.card1.title") }
    }

    public enum Card2 {
      /// Progress in life
      public static var subtitle: String { return L10n.tr("Mainstrings", "intro.card2.subtitle") }
      /// Unlock features in the game by checking off your real life tasks. Earn armor, pets, and more as rewards for meeting your goals. 
      public static var text: String { return L10n.tr("Mainstrings", "intro.card2.text") }
      /// Progress in the game
      public static var title: String { return L10n.tr("Mainstrings", "intro.card2.title") }
    }

    public enum Card3 {
      /// Fight monsters
      public static var subtitle: String { return L10n.tr("Mainstrings", "intro.card3.subtitle") }
      /// Keep your goals on track with help from your friends. Support each other in life and in battle as you improve together!
      public static var text: String { return L10n.tr("Mainstrings", "intro.card3.text") }
      /// Get social
      public static var title: String { return L10n.tr("Mainstrings", "intro.card3.title") }
    }
  }

  public enum Inventory {
    /// Available Until %@
    public static func availableUntil(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "inventory.available_until", p1)
    }
    /// You hatched a new pet!
    public static var hatched: String { return L10n.tr("Mainstrings", "inventory.hatched") }
    /// I just hatched a %@ %@ pet in Habitica by completing my real-life tasks!
    public static func hatchedSharing(_ p1: String, _ p2: String) -> String {
      return L10n.tr("Mainstrings", "inventory.hatchedSharing", p1, p2)
    }
    /// No more Gems available this month. More become available within the first 3 days of each month.
    public static var noGemsLeft: String { return L10n.tr("Mainstrings", "inventory.no_gems_left") }
    /// Monthly Gems: %d/%d Remaining
    public static func numberGemsLeft(_ p1: Int, _ p2: Int) -> String {
      return L10n.tr("Mainstrings", "inventory.number_gems_left", p1, p2)
    }
    /// Only available for %@s. You can change your class from Settings
    public static func wrongClass(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "inventory.wrong_class", p1)
    }
  }

  public enum Locations {
    /// Market
    public static var market: String { return L10n.tr("Mainstrings", "locations.market") }
    /// Quest Shop
    public static var questShop: String { return L10n.tr("Mainstrings", "locations.quest_shop") }
    /// Seasonal Shop
    public static var seasonalShop: String { return L10n.tr("Mainstrings", "locations.seasonal_shop") }
    /// Stable
    public static var stable: String { return L10n.tr("Mainstrings", "locations.stable") }
    /// Tavern
    public static var tavern: String { return L10n.tr("Mainstrings", "locations.tavern") }
  }

  public enum Login {
    /// There was an error with the authentication. Try again later
    public static var authenticationError: String { return L10n.tr("Mainstrings", "login.authentication_error") }
    /// Email a Password Reset Link
    public static var emailPasswordLink: String { return L10n.tr("Mainstrings", "login.email_password_link") }
    /// Email / Username
    public static var emailUsername: String { return L10n.tr("Mainstrings", "login.email_username") }
    /// Enter the email address you used to register your Habitica account.
    public static var enterEmail: String { return L10n.tr("Mainstrings", "login.enter_email") }
    /// Forgot Password
    public static var forgotPassword: String { return L10n.tr("Mainstrings", "login.forgot_password") }
    /// Login
    public static var login: String { return L10n.tr("Mainstrings", "login.login") }
    /// Login with Facebook
    public static var loginFacebook: String { return L10n.tr("Mainstrings", "login.login_facebook") }
    /// Login with Google
    public static var loginGoogle: String { return L10n.tr("Mainstrings", "login.login_google") }
    /// Password and password confirmation have to match.
    public static var passwordConfirmError: String { return L10n.tr("Mainstrings", "login.password_confirm_error") }
    /// Register
    public static var register: String { return L10n.tr("Mainstrings", "login.register") }
    /// If we have your email on file, instructions for setting a new password have been sent to your email.
    public static var resetPasswordResponse: String { return L10n.tr("Mainstrings", "login.reset_password_response") }
  }

  public enum Member {
    /// Last logged in
    public static var lastLoggedIn: String { return L10n.tr("Mainstrings", "member.last_logged_in") }
    /// Member Since
    public static var memberSince: String { return L10n.tr("Mainstrings", "member.member_since") }
  }

  public enum Menu {
    /// Cast Spells
    public static var castSpells: String { return L10n.tr("Mainstrings", "menu.cast_spells") }
    /// Customize Avatar
    public static var customizeAvatar: String { return L10n.tr("Mainstrings", "menu.customize_avatar") }
    /// Gems & Subscriptions
    public static var gemsSubscriptions: String { return L10n.tr("Mainstrings", "menu.gems_subscriptions") }
    /// Help & FAQ
    public static var helpFaq: String { return L10n.tr("Mainstrings", "menu.help_faq") }
    /// Inventory
    public static var inventory: String { return L10n.tr("Mainstrings", "menu.inventory") }
    /// Select Class
    public static var selectClass: String { return L10n.tr("Mainstrings", "menu.select_class") }
    /// Shops
    public static var shops: String { return L10n.tr("Mainstrings", "menu.shops") }
    /// Social
    public static var social: String { return L10n.tr("Mainstrings", "menu.social") }
    /// Use Skills
    public static var useSkills: String { return L10n.tr("Mainstrings", "menu.use_skills") }
  }

  public enum Notifications {
    /// New Bailey Update!
    public static var newBailey: String { return L10n.tr("Mainstrings", "notifications.new_bailey") }
    /// You have %d unallocated Stat Points
    public static func unallocatedStatPoints(_ p1: Int) -> String {
      return L10n.tr("Mainstrings", "notifications.unallocated_stat_points", p1)
    }
  }

  public enum Party {
    /// Create a new Party
    public static var createPartyButton: String { return L10n.tr("Mainstrings", "party.create_party_button") }
    /// Take on quests with friends or on your own. Battle monsters, create Challenges, and help yourself stay accountable through Parties. 
    public static var createPartyDescription: String { return L10n.tr("Mainstrings", "party.create_party_description") }
    /// Play Habitica in a Party
    public static var createPartyTitle: String { return L10n.tr("Mainstrings", "party.create_party_title") }
    /// %@ invited you to join their party
    public static func invitationInvitername(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "party.invitation_invitername", p1)
    }
    /// Someone invited you to join their party
    public static var invitationNoInvitername: String { return L10n.tr("Mainstrings", "party.invitation_no_invitername") }
    /// %@ invited you to participate in a quest
    public static func invitedToQuest(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "party.invited_to_quest", p1)
    }
    /// Give a Party member the username found below and they can send you an invite
    public static var joinPartyDescription: String { return L10n.tr("Mainstrings", "party.join_party_description") }
    /// Want to join a party?
    public static var joinPartyTitle: String { return L10n.tr("Mainstrings", "party.join_party_title") }
    /// Do you want to leave the party and keep or leave the challenges?
    public static var leavePartyDescription: String { return L10n.tr("Mainstrings", "party.leave_party_description") }
    /// Leave Party?
    public static var leavePartyTitle: String { return L10n.tr("Mainstrings", "party.leave_party_title") }
    /// Party Challenges
    public static var partyChallenges: String { return L10n.tr("Mainstrings", "party.party_challenges") }
    /// Party Description
    public static var partyDescription: String { return L10n.tr("Mainstrings", "party.party_description") }
    /// %d/%d Members responded
    public static func questNumberResponded(_ p1: Int, _ p2: Int) -> String {
      return L10n.tr("Mainstrings", "party.quest_number_responded", p1, p2)
    }
    /// %d Participants
    public static func questParticipantCount(_ p1: Int) -> String {
      return L10n.tr("Mainstrings", "party.quest_participant_count", p1)
    }
    /// Start a Quest
    public static var startQuest: String { return L10n.tr("Mainstrings", "party.start_quest") }
  }

  public enum Quests {
    /// Accepted
    public static var accepted: String { return L10n.tr("Mainstrings", "quests.accepted") }
    /// Boss Battle
    public static var bossBattle: String { return L10n.tr("Mainstrings", "quests.boss_battle") }
    /// Collection quest
    public static var collectionQuest: String { return L10n.tr("Mainstrings", "quests.collection_quest") }
    /// Are you sure you want to abort this mission? It will abort it for everyone in your party and all progress will be lost. The quest scroll will be returned to the quest owner.
    public static var confirmAbort: String { return L10n.tr("Mainstrings", "quests.confirm_abort") }
    /// Are you sure you want to cancel this quest? All invitation acceptances will be lost. The quest owner will retain possession of the quest scroll.
    public static var confirmCancelInvitation: String { return L10n.tr("Mainstrings", "quests.confirm_cancel_invitation") }
    /// Are you sure? Not all party members have joined this quest! Quests start automatically when all players have joined or rejected the invitation.
    public static var confirmForceStart: String { return L10n.tr("Mainstrings", "quests.confirm_force_start") }
    /// Invitations
    public static var invitationsHeader: String { return L10n.tr("Mainstrings", "quests.invitations_header") }
    /// Participants
    public static var participantsHeader: String { return L10n.tr("Mainstrings", "quests.participants_header") }
    /// Pending
    public static var pending: String { return L10n.tr("Mainstrings", "quests.pending") }
    /// Rage attack: %@
    public static func rageAttack(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "quests.rage_attack", p1)
    }
    /// Rejected
    public static var rejected: String { return L10n.tr("Mainstrings", "quests.rejected") }
    /// %d Experience Points
    public static func rewardExperience(_ p1: Int) -> String {
      return L10n.tr("Mainstrings", "quests.reward_experience", p1)
    }
    /// %d Gold
    public static func rewardGold(_ p1: Int) -> String {
      return L10n.tr("Mainstrings", "quests.reward_gold", p1)
    }
    /// Started by %@
    public static func startedBy(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "quests.started_by", p1)
    }
  }

  public enum Settings {
    /// API
    public static var api: String { return L10n.tr("Mainstrings", "settings.api") }
    /// Copy these for use in third party applications. However, think of your API Token like a password, and do not share it publicly. You may occasionally be asked for your User ID, but never post your API Token where others can see it, including on Github.
    public static var apiDisclaimer: String { return L10n.tr("Mainstrings", "settings.api_disclaimer") }
    /// App Icon
    public static var appIcon: String { return L10n.tr("Mainstrings", "settings.app_icon") }
    /// Are you sure?
    public static var areYouSure: String { return L10n.tr("Mainstrings", "settings.are_you_sure") }
    /// Authentication
    public static var authentication: String { return L10n.tr("Mainstrings", "settings.authentication") }
    /// Change About Message
    public static var changeAboutMessage: String { return L10n.tr("Mainstrings", "settings.change_about_message") }
    /// Change Class
    public static var changeClass: String { return L10n.tr("Mainstrings", "settings.change_class") }
    /// This will reset your character's class and allocated points (you'll get them all back to re-allocate), and costs 3 gems.
    public static var changeClassDisclaimer: String { return L10n.tr("Mainstrings", "settings.change_class_disclaimer") }
    /// Change Display Name
    public static var changeDisplayName: String { return L10n.tr("Mainstrings", "settings.change_display_name") }
    /// Change Email
    public static var changeEmail: String { return L10n.tr("Mainstrings", "settings.change_email") }
    /// Change Password
    public static var changePassword: String { return L10n.tr("Mainstrings", "settings.change_password") }
    /// Change Photo URL
    public static var changePhotoUrl: String { return L10n.tr("Mainstrings", "settings.change_photo_url") }
    /// Change Username
    public static var changeUsername: String { return L10n.tr("Mainstrings", "settings.change_username") }
    /// Clear Cache
    public static var clearCache: String { return L10n.tr("Mainstrings", "settings.clear_cache") }
    /// Confirm new Password
    public static var confirmNewPassword: String { return L10n.tr("Mainstrings", "settings.confirm_new_password") }
    /// Confirming your username will make it public for invitations, @mentions and messaging. You can change your username from settings at any time.
    public static var confirmUsernameDescription: String { return L10n.tr("Mainstrings", "settings.confirm_username_description") }
    /// Are you sure you want to confirm your current username?
    public static var confirmUsernamePrompt: String { return L10n.tr("Mainstrings", "settings.confirm_username_prompt") }
    /// Custom Day Start
    public static var customDayStart: String { return L10n.tr("Mainstrings", "settings.custom_day_start") }
    /// Daily Reminder
    public static var dailyReminder: String { return L10n.tr("Mainstrings", "settings.daily_reminder") }
    /// Danger Zone
    public static var dangerZone: String { return L10n.tr("Mainstrings", "settings.danger_zone") }
    /// Day Start
    public static var dayStart: String { return L10n.tr("Mainstrings", "settings.day_start") }
    /// Delete Account
    public static var deleteAccount: String { return L10n.tr("Mainstrings", "settings.delete_account") }
    /// Are you sure? This will delete your account forever, and it can never be restored! You will need to register a new account to use Habitica again. Banked or spent Gems will not be refunded. If you're absolutely certain, type your password into the text box below.
    public static var deleteAccountDescription: String { return L10n.tr("Mainstrings", "settings.delete_account_description") }
    /// Disable all Push Notifications
    public static var disableAllNotifications: String { return L10n.tr("Mainstrings", "settings.disable_all_notifications") }
    /// Disable Private Messages
    public static var disablePm: String { return L10n.tr("Mainstrings", "settings.disable_pm") }
    /// Your display name has to be between 1 and 30 characters.
    public static var displayNameLengthError: String { return L10n.tr("Mainstrings", "settings.display_name_length_error") }
    /// Display Notification Badge
    public static var displayNotificationBadge: String { return L10n.tr("Mainstrings", "settings.display_notification_badge") }
    /// Enable Class System
    public static var enableClassSystem: String { return L10n.tr("Mainstrings", "settings.enable_class_system") }
    /// Every day at
    public static var everyDay: String { return L10n.tr("Mainstrings", "settings.every_day") }
    /// Fix Character Values
    public static var fixCharacterValues: String { return L10n.tr("Mainstrings", "settings.fix_characterValues") }
    /// If you’ve encountered a bug or made a mistake that unfairly changed your character, you can manually correct those values here.
    public static var fixValuesDescription: String { return L10n.tr("Mainstrings", "settings.fix_values_description") }
    /// Language
    public static var language: String { return L10n.tr("Mainstrings", "settings.language") }
    /// Local
    public static var local: String { return L10n.tr("Mainstrings", "settings.local") }
    /// Log Out
    public static var logOut: String { return L10n.tr("Mainstrings", "settings.log_out") }
    /// Login Methods
    public static var loginMethods: String { return L10n.tr("Mainstrings", "settings.login_methods") }
    /// Maintenance
    public static var maintenance: String { return L10n.tr("Mainstrings", "settings.maintenance") }
    /// Mentions
    public static var mentions: String { return L10n.tr("Mainstrings", "settings.mentions") }
    /// New Email
    public static var newEmail: String { return L10n.tr("Mainstrings", "settings.new_email") }
    /// New Password
    public static var newPassword: String { return L10n.tr("Mainstrings", "settings.new_password") }
    /// New Username
    public static var newUsername: String { return L10n.tr("Mainstrings", "settings.new_username") }
    /// Notification Badge
    public static var notificationBadge: String { return L10n.tr("Mainstrings", "settings.notification_badge") }
    /// Old Password
    public static var oldPassword: String { return L10n.tr("Mainstrings", "settings.old_password") }
    /// Preferences
    public static var preferences: String { return L10n.tr("Mainstrings", "settings.preferences") }
    /// Profile
    public static var profile: String { return L10n.tr("Mainstrings", "settings.profile") }
    /// Push Notifications
    public static var pushNotifications: String { return L10n.tr("Mainstrings", "settings.push_notifications") }
    /// Reload Content
    public static var reloadContent: String { return L10n.tr("Mainstrings", "settings.reload_content") }
    /// Reminder
    public static var reminder: String { return L10n.tr("Mainstrings", "settings.reminder") }
    /// Reset Account
    public static var resetAccount: String { return L10n.tr("Mainstrings", "settings.reset_account") }
    /// WARNING! This resets many parts of your account. This is highly discouraged, but some people find it useful in the beginning after playing with the site for a short time.\n\nYou will lose all your levels, gold, and experience points. All your tasks (except those from challenges) will be deleted permanently and you will lose all of their historical data. You will lose all your equipment but you will be able to buy it all back, including all limited edition equipment or subscriber Mystery items that you already own (you will need to be in the correct class to re-buy class-specific gear). You will keep your current class and your pets and mounts. You might prefer to use an Orb of Rebirth instead, which is a much safer option and which will preserve your tasks and equipment.
    public static var resetAccountDescription: String { return L10n.tr("Mainstrings", "settings.reset_account_description") }
    /// Everywhere
    public static var searchableEverywhere: String { return L10n.tr("Mainstrings", "settings.searchable_everywhere") }
    /// Only Private Spaces
    public static var searchablePrivateSpaces: String { return L10n.tr("Mainstrings", "settings.searchable_private_spaces") }
    /// Suggest my username
    public static var searchableUsername: String { return L10n.tr("Mainstrings", "settings.searchable_username") }
    /// Select Class
    public static var selectClass: String { return L10n.tr("Mainstrings", "settings.select_class") }
    /// Server
    public static var server: String { return L10n.tr("Mainstrings", "settings.server") }
    /// Social
    public static var social: String { return L10n.tr("Mainstrings", "settings.social") }
    /// Sound Theme
    public static var soundTheme: String { return L10n.tr("Mainstrings", "settings.sound_theme") }
    /// Theme Color
    public static var themeColor: String { return L10n.tr("Mainstrings", "settings.theme_color") }
    /// User
    public static var user: String { return L10n.tr("Mainstrings", "settings.user") }
    /// Username not confirmed
    public static var usernameNotConfirmed: String { return L10n.tr("Mainstrings", "settings.username_not_confirmed") }
    /// Incorrect Password
    public static var wrongPassword: String { return L10n.tr("Mainstrings", "settings.wrong_password") }
  }

  public enum Shops {
    /// You can only purchase gear for your current class
    public static var otherClassDisclaimer: String { return L10n.tr("Mainstrings", "shops.other_class_disclaimer") }
    /// You already have all your class equipment! More will be released during the Grand Galas, near the solstices and equinoxes.
    public static var purchasedAllGear: String { return L10n.tr("Mainstrings", "shops.purchased_all_gear") }
  }

  public enum Skills {
    /// Can't cast a spell on a challenge task
    public static var cantCastOnChallengeTasks: String { return L10n.tr("Mainstrings", "skills.cant_cast_on_challenge_tasks") }
    /// Transformation Items
    public static var transformationItems: String { return L10n.tr("Mainstrings", "skills.transformation_items") }
    /// Unlocks at level %d
    public static func unlocksAt(_ p1: Int) -> String {
      return L10n.tr("Mainstrings", "skills.unlocks_at", p1)
    }
    /// You use %@
    public static func useSkill(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "skills.use_skill", p1)
    }
    /// You used %@
    public static func usedTransformationItem(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "skills.used_transformation_item", p1)
    }
  }

  public enum Stable {
    /// Feed
    public static var feed: String { return L10n.tr("Mainstrings", "stable.feed") }
    /// Magic Potion
    public static var premium: String { return L10n.tr("Mainstrings", "stable.premium") }
    /// Quest Mounts
    public static var questMounts: String { return L10n.tr("Mainstrings", "stable.quest_mounts") }
    /// Quest Pets
    public static var questPets: String { return L10n.tr("Mainstrings", "stable.quest_pets") }
    /// Special Mounts
    public static var specialMounts: String { return L10n.tr("Mainstrings", "stable.special_mounts") }
    /// Special Pets
    public static var specialPets: String { return L10n.tr("Mainstrings", "stable.special_pets") }
    /// Standard
    public static var standard: String { return L10n.tr("Mainstrings", "stable.standard") }
    /// Standard Mounts
    public static var standardMounts: String { return L10n.tr("Mainstrings", "stable.standard_mounts") }
    /// Standard Pets
    public static var standardPets: String { return L10n.tr("Mainstrings", "stable.standard_pets") }
    /// Wacky Mounts
    public static var wackyMounts: String { return L10n.tr("Mainstrings", "stable.wacky_mounts") }
    /// Wacky Pets
    public static var wackyPets: String { return L10n.tr("Mainstrings", "stable.wacky_pets") }
  }

  public enum Stats {
    /// Allocated
    public static var allocated: String { return L10n.tr("Mainstrings", "stats.allocated") }
    /// Auto Allocate Points
    public static var autoAllocatePoints: String { return L10n.tr("Mainstrings", "stats.auto_allocate_points") }
    /// Battle Gear
    public static var battleGear: String { return L10n.tr("Mainstrings", "stats.battle_gear") }
    /// Buffs
    public static var buffs: String { return L10n.tr("Mainstrings", "stats.buffs") }
    /// Each level earns you one point to assign to an attribute of your choice. You can do so manually, or let the game decide for you using one of the Automatic Allocation options.
    public static var characterBuildText: String { return L10n.tr("Mainstrings", "stats.character_build_text") }
    /// Character Build
    public static var characterBuildTitle: String { return L10n.tr("Mainstrings", "stats.character_build_title") }
    /// Class-Bonus
    public static var classBonus: String { return L10n.tr("Mainstrings", "stats.class_bonus") }
    /// Decreases the amount of damage taken from your tasks. Does not decrease the damage received from bosses.
    public static var constitutionText: String { return L10n.tr("Mainstrings", "stats.constitution_text") }
    /// Constitution
    public static var constitutionTitle: String { return L10n.tr("Mainstrings", "stats.constitution_title") }
    /// Distribute based on class
    public static var distributeClass: String { return L10n.tr("Mainstrings", "stats.distribute_class") }
    /// Assigns more points to the attributes important to your Class.
    public static var distributeClassHelp: String { return L10n.tr("Mainstrings", "stats.distribute_class_help") }
    /// Distribute evenly
    public static var distributeEvenly: String { return L10n.tr("Mainstrings", "stats.distribute_evenly") }
    /// Assigns the same number of points to each attribute.
    public static var distributeEvenlyHelp: String { return L10n.tr("Mainstrings", "stats.distribute_evenly_help") }
    /// Distribute based on task activity
    public static var distributeTasks: String { return L10n.tr("Mainstrings", "stats.distribute_tasks") }
    /// Assigns points based on the Strength, Intelligence, Constitution, and Perception categories associated with the tasks you complete.
    public static var distributeTasksHelp: String { return L10n.tr("Mainstrings", "stats.distribute_tasks_help") }
    /// Increases EXP earned from completing tasks. Also increases your mana cap and how fast mana regenerates over time.
    public static var intelligenceText: String { return L10n.tr("Mainstrings", "stats.intelligence_text") }
    /// Intelligence
    public static var intelligenceTitle: String { return L10n.tr("Mainstrings", "stats.intelligence_title") }
    /// Level
    public static var level: String { return L10n.tr("Mainstrings", "stats.level") }
    /// 0 Points to Allocate
    public static var noPointsToAllocate: String { return L10n.tr("Mainstrings", "stats.no_points_to_allocate") }
    /// 1 Point to Allocate
    public static var onePointToAllocate: String { return L10n.tr("Mainstrings", "stats.one_point_to_allocate") }
    /// Increases the likelihood of finding drops when completing Tasks, the daily drop-cap, Streak Bonuses, and the amount of gold awarded for Tasks.
    public static var perceptionText: String { return L10n.tr("Mainstrings", "stats.perception_text") }
    /// Perception
    public static var perceptionTitle: String { return L10n.tr("Mainstrings", "stats.perception_title") }
    /// %d Point to Allocate
    public static func pointsToAllocate(_ p1: Int) -> String {
      return L10n.tr("Mainstrings", "stats.points_to_allocate", p1)
    }
    /// Stat guide
    public static var statGuide: String { return L10n.tr("Mainstrings", "stats.stat_guide") }
    /// Increases the bonus of critical hits and makes them more likely when scoring a task. Also increases damage dealt to bosses. 
    public static var strengthText: String { return L10n.tr("Mainstrings", "stats.strength_text") }
    /// Strength
    public static var strengthTitle: String { return L10n.tr("Mainstrings", "stats.strength_title") }
    /// Total
    public static var total: String { return L10n.tr("Mainstrings", "stats.total") }
  }

  public enum Tasks {
    /// Add %@
    public static func addX(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "tasks.add_x", p1)
    }
    /// Chores
    public static var chores: String { return L10n.tr("Mainstrings", "tasks.chores") }
    /// Creativity
    public static var creativity: String { return L10n.tr("Mainstrings", "tasks.creativity") }
    /// Dailies
    public static var dailies: String { return L10n.tr("Mainstrings", "tasks.dailies") }
    /// Daily
    public static var daily: String { return L10n.tr("Mainstrings", "tasks.daily") }
    /// Due in %d days
    public static func dueInXDays(_ p1: Int) -> String {
      return L10n.tr("Mainstrings", "tasks.due_in_x_days", p1)
    }
    /// Due today
    public static var dueToday: String { return L10n.tr("Mainstrings", "tasks.due_today") }
    /// Due tomorrow
    public static var dueTomorrow: String { return L10n.tr("Mainstrings", "tasks.due_tomorrow") }
    /// Due %@
    public static func dueX(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "tasks.due_x", p1)
    }
    /// every %d %@
    public static func everyX(_ p1: Int, _ p2: String) -> String {
      return L10n.tr("Mainstrings", "tasks.every_x", p1, p2)
    }
    /// Exercise
    public static var exercise: String { return L10n.tr("Mainstrings", "tasks.exercise") }
    /// Habit
    public static var habit: String { return L10n.tr("Mainstrings", "tasks.habit") }
    /// Habits
    public static var habits: String { return L10n.tr("Mainstrings", "tasks.habits") }
    /// Health
    public static var health: String { return L10n.tr("Mainstrings", "tasks.health") }
    /// Reward
    public static var reward: String { return L10n.tr("Mainstrings", "tasks.reward") }
    /// Rewards
    public static var rewards: String { return L10n.tr("Mainstrings", "tasks.rewards") }
    /// School
    public static var school: String { return L10n.tr("Mainstrings", "tasks.school") }
    /// Team
    public static var team: String { return L10n.tr("Mainstrings", "tasks.team") }
    /// To-Do
    public static var todo: String { return L10n.tr("Mainstrings", "tasks.todo") }
    /// To-Dos
    public static var todos: String { return L10n.tr("Mainstrings", "tasks.todos") }
    /// Work
    public static var work: String { return L10n.tr("Mainstrings", "tasks.work") }

    public enum Examples {
      /// Tap to choose your schedule!
      public static var choresDailyNotes: String { return L10n.tr("Mainstrings", "tasks.examples.chores_daily_notes") }
      /// Wash dishes
      public static var choresDailyText: String { return L10n.tr("Mainstrings", "tasks.examples.chores_daily_text") }
      /// 10 minutes cleaning
      public static var choresHabit: String { return L10n.tr("Mainstrings", "tasks.examples.chores_habit") }
      /// Tap to specify the cluttered area!
      public static var choresTodoNotes: String { return L10n.tr("Mainstrings", "tasks.examples.chores_todo_notes") }
      /// Organize clutter
      public static var choresTodoText: String { return L10n.tr("Mainstrings", "tasks.examples.chores_todo_text") }
      /// Tap to specify the name of your current project + set the schedule!
      public static var creativityDailyNotes: String { return L10n.tr("Mainstrings", "tasks.examples.creativity_daily_notes") }
      /// Work on creative project
      public static var creativityDailyText: String { return L10n.tr("Mainstrings", "tasks.examples.creativity_daily_text") }
      /// Practiced a new creative technique
      public static var creativityHabit: String { return L10n.tr("Mainstrings", "tasks.examples.creativity_habit") }
      /// Tap to specify the name of your project
      public static var creativityTodoNotes: String { return L10n.tr("Mainstrings", "tasks.examples.creativity_todo_notes") }
      /// Finish creative project
      public static var creativityTodoText: String { return L10n.tr("Mainstrings", "tasks.examples.creativity_todo_text") }
      /// Tap to choose your schedule and specify exercises!
      public static var exerciseDailyNotes: String { return L10n.tr("Mainstrings", "tasks.examples.exercise_daily_notes") }
      /// Daily workout routine
      public static var exerciseDailyText: String { return L10n.tr("Mainstrings", "tasks.examples.exercise_daily_text") }
      /// 10 minutes cardio
      public static var exerciseHabit: String { return L10n.tr("Mainstrings", "tasks.examples.exercise_habit") }
      /// Tap to add a checklist!
      public static var exerciseTodoNotes: String { return L10n.tr("Mainstrings", "tasks.examples.exercise_todo_notes") }
      /// Set up workout schedule
      public static var exerciseTodoText: String { return L10n.tr("Mainstrings", "tasks.examples.exercise_todo_text") }
      /// Or delete it by swiping left
      public static var habitNotes: String { return L10n.tr("Mainstrings", "tasks.examples.habit_notes") }
      /// Tap here to edit this into a bad habit you'd like to quit
      public static var habitText: String { return L10n.tr("Mainstrings", "tasks.examples.habit_text") }
      /// Tap to make any changes!
      public static var healthDailyNotes: String { return L10n.tr("Mainstrings", "tasks.examples.health_daily_notes") }
      /// Floss
      public static var healthDailyText: String { return L10n.tr("Mainstrings", "tasks.examples.health_daily_text") }
      /// Eat health/junk food
      public static var healthHabit: String { return L10n.tr("Mainstrings", "tasks.examples.health_habit") }
      /// Tap to add checklists!
      public static var healthTodoNotes: String { return L10n.tr("Mainstrings", "tasks.examples.health_todo_notes") }
      /// Brainstorm a healthy change
      public static var healthTodoText: String { return L10n.tr("Mainstrings", "tasks.examples.health_todo_text") }
      /// Watch TV, play a game, eat a treat, it’s up to you!
      public static var rewardNotes: String { return L10n.tr("Mainstrings", "tasks.examples.reward_notes") }
      /// Reward yourself
      public static var rewardText: String { return L10n.tr("Mainstrings", "tasks.examples.reward_text") }
      /// Tap to specify your most important task
      public static var schoolDailyNotes: String { return L10n.tr("Mainstrings", "tasks.examples.school_daily_notes") }
      /// Do homework
      public static var schoolDailyText: String { return L10n.tr("Mainstrings", "tasks.examples.school_daily_text") }
      /// Study/Procrastinate
      public static var schoolHabit: String { return L10n.tr("Mainstrings", "tasks.examples.school_habit") }
      /// Tap to specify your most important task
      public static var schoolTodoNotes: String { return L10n.tr("Mainstrings", "tasks.examples.school_todo_notes") }
      /// Finish assignment for class
      public static var schoolTodoText: String { return L10n.tr("Mainstrings", "tasks.examples.school_todo_text") }
      /// Tap to specify your most important task
      public static var teamDailyNotes: String { return L10n.tr("Mainstrings", "tasks.examples.team_daily_notes") }
      /// Update team on status
      public static var teamDailyText: String { return L10n.tr("Mainstrings", "tasks.examples.team_daily_text") }
      /// Check in with team
      public static var teamHabit: String { return L10n.tr("Mainstrings", "tasks.examples.team_habit") }
      /// Tap to specify your most important task
      public static var teamTodoNotes: String { return L10n.tr("Mainstrings", "tasks.examples.team_todo_notes") }
      /// Complete team project
      public static var teamTodoText: String { return L10n.tr("Mainstrings", "tasks.examples.team_todo_text") }
      /// You can either complete this To-Do, edit it, or remove it.
      public static var todoNotes: String { return L10n.tr("Mainstrings", "tasks.examples.todo_notes") }
      /// Join Habitica (Check me off!)
      public static var todoText: String { return L10n.tr("Mainstrings", "tasks.examples.todo_text") }
      /// Tap to specify your most important task
      public static var workDailyNotes: String { return L10n.tr("Mainstrings", "tasks.examples.work_daily_notes") }
      /// Worked on today’s most important task
      public static var workDailyText: String { return L10n.tr("Mainstrings", "tasks.examples.work_daily_text") }
      /// Process email
      public static var workHabit: String { return L10n.tr("Mainstrings", "tasks.examples.work_habit") }
      /// Tap to specify the name of your current project + set a due date!
      public static var workTodoNotes: String { return L10n.tr("Mainstrings", "tasks.examples.work_todo_notes") }
      /// Complete work project
      public static var workTodoText: String { return L10n.tr("Mainstrings", "tasks.examples.work_todo_text") }
    }

    public enum Form {
      /// Checklist
      public static var checklist: String { return L10n.tr("Mainstrings", "tasks.form.checklist") }
      /// Clear
      public static var clear: String { return L10n.tr("Mainstrings", "tasks.form.clear") }
      /// Are you sure you want to delete this task?
      public static var confirmDelete: String { return L10n.tr("Mainstrings", "tasks.form.confirm_delete") }
      /// Controls
      public static var controls: String { return L10n.tr("Mainstrings", "tasks.form.controls") }
      /// Cost
      public static var cost: String { return L10n.tr("Mainstrings", "tasks.form.cost") }
      /// New %@
      public static func create(_ p1: String) -> String {
        return L10n.tr("Mainstrings", "tasks.form.create", p1)
      }
      /// What do you want to do regularly?
      public static var dailiesTitlePlaceholder: String { return L10n.tr("Mainstrings", "tasks.form.dailies_title_placeholder") }
      /// Day of the month
      public static var dayOfMonth: String { return L10n.tr("Mainstrings", "tasks.form.day_of_month") }
      /// Day of the week
      public static var dayOfWeek: String { return L10n.tr("Mainstrings", "tasks.form.day_of_week") }
      /// Difficulty
      public static var difficulty: String { return L10n.tr("Mainstrings", "tasks.form.difficulty") }
      /// Due date
      public static var dueDate: String { return L10n.tr("Mainstrings", "tasks.form.due_date") }
      /// Easy
      public static var easy: String { return L10n.tr("Mainstrings", "tasks.form.easy") }
      /// Edit %@
      public static func edit(_ p1: String) -> String {
        return L10n.tr("Mainstrings", "tasks.form.edit", p1)
      }
      /// Every
      public static var every: String { return L10n.tr("Mainstrings", "tasks.form.every") }
      /// What habits do you want to foster or break?
      public static var habitTitlePlaceholder: String { return L10n.tr("Mainstrings", "tasks.form.habit_title_placeholder") }
      /// Hard
      public static var hard: String { return L10n.tr("Mainstrings", "tasks.form.hard") }
      /// Medium
      public static var medium: String { return L10n.tr("Mainstrings", "tasks.form.medium") }
      /// New checklist item
      public static var newChecklistItem: String { return L10n.tr("Mainstrings", "tasks.form.new_checklist_item") }
      /// New reminder
      public static var newReminder: String { return L10n.tr("Mainstrings", "tasks.form.new_reminder") }
      /// Include any notes to help you out
      public static var notesPlaceholder: String { return L10n.tr("Mainstrings", "tasks.form.notes_placeholder") }
      /// Remind me
      public static var remindMe: String { return L10n.tr("Mainstrings", "tasks.form.remind_me") }
      /// Reminders
      public static var reminders: String { return L10n.tr("Mainstrings", "tasks.form.reminders") }
      /// Repeats
      public static var repeats: String { return L10n.tr("Mainstrings", "tasks.form.repeats") }
      /// Reset Streak
      public static var resetStreak: String { return L10n.tr("Mainstrings", "tasks.form.reset_streak") }
      /// How do you want to reward yourself?
      public static var rewardsTitlePlaceholder: String { return L10n.tr("Mainstrings", "tasks.form.rewards_title_placeholder") }
      /// Scheduling
      public static var scheduling: String { return L10n.tr("Mainstrings", "tasks.form.scheduling") }
      /// Start date
      public static var startDate: String { return L10n.tr("Mainstrings", "tasks.form.start_date") }
      /// Tags
      public static var tags: String { return L10n.tr("Mainstrings", "tasks.form.tags") }
      /// What do you want to complete once?
      public static var todosTitlePlaceholder: String { return L10n.tr("Mainstrings", "tasks.form.todos_title_placeholder") }
      /// Trivial
      public static var trivial: String { return L10n.tr("Mainstrings", "tasks.form.trivial") }

      public enum Accessibility {
        /// Disable %@
        public static func disable(_ p1: String) -> String {
          return L10n.tr("Mainstrings", "tasks.form.accessibility.disable", p1)
        }
        /// Disable negative action.
        public static var disableNegative: String { return L10n.tr("Mainstrings", "tasks.form.accessibility.disable_negative") }
        /// Disable positive action.
        public static var disablePositive: String { return L10n.tr("Mainstrings", "tasks.form.accessibility.disable_positive") }
        /// Enable %@
        public static func enable(_ p1: String) -> String {
          return L10n.tr("Mainstrings", "tasks.form.accessibility.enable", p1)
        }
        /// Enable negative action.
        public static var enableNegative: String { return L10n.tr("Mainstrings", "tasks.form.accessibility.enable_negative") }
        /// Enable positive action.
        public static var enablePositive: String { return L10n.tr("Mainstrings", "tasks.form.accessibility.enable_positive") }
        /// Negative habit action enabled.
        public static var negativeEnabled: String { return L10n.tr("Mainstrings", "tasks.form.accessibility.negative_enabled") }
        /// Positive and negative habit actions enabled.
        public static var positiveAndNegativeEnabled: String { return L10n.tr("Mainstrings", "tasks.form.accessibility.positive_and_negative_enabled") }
        /// Positive habit action enabled.
        public static var positiveEnabled: String { return L10n.tr("Mainstrings", "tasks.form.accessibility.positive_enabled") }
        /// Change difficuly to %@
        public static func setTaskDifficulty(_ p1: String) -> String {
          return L10n.tr("Mainstrings", "tasks.form.accessibility.set_task_difficulty", p1)
        }
        /// Difficuly is %@
        public static func taskDifficulty(_ p1: String) -> String {
          return L10n.tr("Mainstrings", "tasks.form.accessibility.task_difficulty", p1)
        }
      }
    }

    public enum Quality {
      /// Bad
      public static var bad: String { return L10n.tr("Mainstrings", "tasks.quality.bad") }
      /// Best
      public static var best: String { return L10n.tr("Mainstrings", "tasks.quality.best") }
      /// Better
      public static var better: String { return L10n.tr("Mainstrings", "tasks.quality.better") }
      /// Good
      public static var good: String { return L10n.tr("Mainstrings", "tasks.quality.good") }
      /// Neutral
      public static var neutral: String { return L10n.tr("Mainstrings", "tasks.quality.neutral") }
      /// Worse
      public static var worse: String { return L10n.tr("Mainstrings", "tasks.quality.worse") }
      /// Worst
      public static var worst: String { return L10n.tr("Mainstrings", "tasks.quality.worst") }
    }

    public enum Repeats {
      /// daily
      public static var daily: String { return L10n.tr("Mainstrings", "tasks.repeats.daily") }
      /// every day
      public static var everyDay: String { return L10n.tr("Mainstrings", "tasks.repeats.every_day") }
      /// monthly
      public static var monthly: String { return L10n.tr("Mainstrings", "tasks.repeats.monthly") }
      /// the %@
      public static func monthlyThe(_ p1: String) -> String {
        return L10n.tr("Mainstrings", "tasks.repeats.monthly_the", p1)
      }
      /// Repeats %@
      public static func repeatsEvery(_ p1: String) -> String {
        return L10n.tr("Mainstrings", "tasks.repeats.repeats_every", p1)
      }
      /// Repeats %@ on %@
      public static func repeatsEveryOn(_ p1: String, _ p2: String) -> String {
        return L10n.tr("Mainstrings", "tasks.repeats.repeats_every_on", p1, p2)
      }
      /// weekdays
      public static var weekdays: String { return L10n.tr("Mainstrings", "tasks.repeats.weekdays") }
      /// weekends
      public static var weekends: String { return L10n.tr("Mainstrings", "tasks.repeats.weekends") }
      /// weekly
      public static var weekly: String { return L10n.tr("Mainstrings", "tasks.repeats.weekly") }
      /// yearly
      public static var yearly: String { return L10n.tr("Mainstrings", "tasks.repeats.yearly") }
    }
  }

  public enum Theme {
    /// Blue
    public static var blue: String { return L10n.tr("Mainstrings", "theme.blue") }
    /// Default
    public static var defaultTheme: String { return L10n.tr("Mainstrings", "theme.default_theme") }
    /// Green
    public static var green: String { return L10n.tr("Mainstrings", "theme.green") }
    /// Maroon
    public static var maroon: String { return L10n.tr("Mainstrings", "theme.maroon") }
    /// Orange
    public static var orange: String { return L10n.tr("Mainstrings", "theme.orange") }
    /// Red
    public static var red: String { return L10n.tr("Mainstrings", "theme.red") }
    /// Teal
    public static var teal: String { return L10n.tr("Mainstrings", "theme.teal") }
    /// Yellow
    public static var yellow: String { return L10n.tr("Mainstrings", "theme.yellow") }
  }

  public enum Titles {
    /// About
    public static var about: String { return L10n.tr("Mainstrings", "titles.about") }
    /// API
    public static var api: String { return L10n.tr("Mainstrings", "titles.api") }
    /// Authentication
    public static var authentication: String { return L10n.tr("Mainstrings", "titles.authentication") }
    /// Avatar
    public static var avatar: String { return L10n.tr("Mainstrings", "titles.avatar") }
    /// Challenges
    public static var challenges: String { return L10n.tr("Mainstrings", "titles.challenges") }
    /// Choose Recipient
    public static var chooseRecipient: String { return L10n.tr("Mainstrings", "titles.choose_recipient") }
    /// Choose User
    public static var chooseUser: String { return L10n.tr("Mainstrings", "titles.choose_user") }
    /// Equipment
    public static var equipment: String { return L10n.tr("Mainstrings", "titles.equipment") }
    /// FAQ
    public static var faq: String { return L10n.tr("Mainstrings", "titles.faq") }
    /// Feed Pet
    public static var feedPet: String { return L10n.tr("Mainstrings", "titles.feed_pet") }
    /// Fix Values
    public static var fixValues: String { return L10n.tr("Mainstrings", "titles.fix_values") }
    /// Gift Subscription
    public static var giftSubscription: String { return L10n.tr("Mainstrings", "titles.gift_subscription") }
    /// Guidelines
    public static var guidelines: String { return L10n.tr("Mainstrings", "titles.guidelines") }
    /// Guild
    public static var guild: String { return L10n.tr("Mainstrings", "titles.guild") }
    /// Guilds
    public static var guilds: String { return L10n.tr("Mainstrings", "titles.guilds") }
    /// Invite Members
    public static var inviteMembers: String { return L10n.tr("Mainstrings", "titles.invite_members") }
    /// Items
    public static var items: String { return L10n.tr("Mainstrings", "titles.items") }
    /// Messages
    public static var messages: String { return L10n.tr("Mainstrings", "titles.messages") }
    /// Mounts
    public static var mounts: String { return L10n.tr("Mainstrings", "titles.mounts") }
    /// News
    public static var news: String { return L10n.tr("Mainstrings", "titles.news") }
    /// Notifications
    public static var notifications: String { return L10n.tr("Mainstrings", "titles.notifications") }
    /// Party
    public static var party: String { return L10n.tr("Mainstrings", "titles.party") }
    /// Pets
    public static var pets: String { return L10n.tr("Mainstrings", "titles.pets") }
    /// Profile
    public static var profile: String { return L10n.tr("Mainstrings", "titles.profile") }
    /// Select Class
    public static var selectClass: String { return L10n.tr("Mainstrings", "titles.select_class") }
    /// Settings
    public static var settings: String { return L10n.tr("Mainstrings", "titles.settings") }
    /// Shops
    public static var shops: String { return L10n.tr("Mainstrings", "titles.shops") }
    /// Skills
    public static var skills: String { return L10n.tr("Mainstrings", "titles.skills") }
    /// Spells
    public static var spells: String { return L10n.tr("Mainstrings", "titles.spells") }
    /// Stable
    public static var stable: String { return L10n.tr("Mainstrings", "titles.stable") }
    /// Stats
    public static var stats: String { return L10n.tr("Mainstrings", "titles.stats") }
    /// Tavern
    public static var tavern: String { return L10n.tr("Mainstrings", "titles.tavern") }
  }

  public enum Tutorials {
    /// Tap to add a new task.
    public static var addTask: String { return L10n.tr("Mainstrings", "tutorials.add_task") }
    /// Make Dailies for time-sensitive tasks that need to be done on a regular schedule.
    public static var dailies1: String { return L10n.tr("Mainstrings", "tutorials.dailies_1") }
    /// Be careful — if you miss one, your avatar will take damage overnight. Checking them off consistently brings great rewards!
    public static var dailies2: String { return L10n.tr("Mainstrings", "tutorials.dailies_2") }
    /// Tap a task to edit it and add reminders. Swipe left to delete it.
    public static var editTask: String { return L10n.tr("Mainstrings", "tutorials.edit_task") }
    /// Tap to filter tasks.
    public static var filterTask: String { return L10n.tr("Mainstrings", "tutorials.filter_task") }
    /// First up is Habits. They can be positive Habits you want to improve or negative Habits you want to quit.
    public static var habits1: String { return L10n.tr("Mainstrings", "tutorials.habits_1") }
    /// Every time you do a positive Habit, tap the + to get experience and gold!
    public static var habits2: String { return L10n.tr("Mainstrings", "tutorials.habits_2") }
    /// If you slip up and do a negative Habit, tapping the - will reduce your avatar’s health to help you stay accountable.
    public static var habits3: String { return L10n.tr("Mainstrings", "tutorials.habits_3") }
    /// Give it a shot! You can explore the other task types through the bottom navigation.
    public static var habits4: String { return L10n.tr("Mainstrings", "tutorials.habits_4") }
    /// This is where you can read and reply to private messages! You can also message people from their profiles.
    public static var inbox: String { return L10n.tr("Mainstrings", "tutorials.inbox") }
    /// Hold down on a task to drag it around.
    public static var reorderTask: String { return L10n.tr("Mainstrings", "tutorials.reorder_task") }
    /// Buy gear for your avatar with the gold you earn!
    public static var rewards1: String { return L10n.tr("Mainstrings", "tutorials.rewards_1") }
    /// You can also make real-world Custom Rewards based on what motivates you.
    public static var rewards2: String { return L10n.tr("Mainstrings", "tutorials.rewards_2") }
    /// Skills are special abilities that have powerful effects! Tap on a skill to use it. It will cost Mana (the blue bar), which you earn by checking in every day and by completing your real-life tasks. Check out the FAQ in the menu for more info!
    public static var spells: String { return L10n.tr("Mainstrings", "tutorials.spells") }
    /// Tap the gray button to allocate lots of your stats at once, or tap the arrows to add them one point at a time.
    public static var stats: String { return L10n.tr("Mainstrings", "tutorials.stats") }
    /// Use To-Dos to keep track of tasks you need to do just once.
    public static var todos1: String { return L10n.tr("Mainstrings", "tutorials.todos_1") }
    /// If your To-Do has to be done by a certain time, set a due date. Looks like you can check one off — go ahead!
    public static var todos2: String { return L10n.tr("Mainstrings", "tutorials.todos_2") }
  }

  public enum WorldBoss {
    /// Defeat the Boss to earn special rewards and save Habitica from %@'s Terror!
    public static func actionPrompt(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "world_boss.action_prompt", p1)
    }
    /// A World Boss is a special event where the whole community works together to take down a powerful monster with their tasks!
    public static var description: String { return L10n.tr("Mainstrings", "world_boss.description") }
    /// Complete tasks to damage the Boss
    public static var firstBullet: String { return L10n.tr("Mainstrings", "world_boss.first_bullet") }
    /// Check the Tavern to see Boss progress and Rage attacks
    public static var fourthBullet: String { return L10n.tr("Mainstrings", "world_boss.fourth_bullet") }
    /// Pending Strike
    public static var pendingStrike: String { return L10n.tr("Mainstrings", "world_boss.pending_strike") }
    /// %@ is Heartbroken!\nOur beloved %@ was devastated when %@ shattered the %@. Quickly, tackle your tasks to defeat the monster and help rebuild!
    public static func rageStrikeDamaged(_ p1: String, _ p2: String, _ p3: String, _ p4: String) -> String {
      return L10n.tr("Mainstrings", "world_boss.rage_strike_damaged", p1, p2, p3, p4)
    }
    /// There are 3 potential Rage Strikes\nThis gauge fills when Habiticans miss their Dailies. If it fills up, the DysHeartener will unleash its Shattering Heartbreak attack on one of Habitica's shopkeepers, so be sure to do your tasks!
    public static var rageStrikeExplanation: String { return L10n.tr("Mainstrings", "world_boss.rage_strike_explanation") }
    /// What's a Rage Strike?
    public static var rageStrikeExplanationButton: String { return L10n.tr("Mainstrings", "world_boss.rage_strike_explanation_button") }
    /// The %@ was Attacked!
    public static func rageStrikeTitle(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "world_boss.rage_strike_title", p1)
    }
    /// Be careful...\nThe World Boss will lash out and attack one of our friendly shopkeepers once its rage bar fills. Keep up with your Dailies to try and prevent it from happening!
    public static var rageStrikeWarning: String { return L10n.tr("Mainstrings", "world_boss.rage_strike_warning") }
    /// The Boss won’t damage you for missed tasks, but its Rage meter will go up. If the bar fills up, the Boss will attack one of the shopkeepers!
    public static var secondBullet: String { return L10n.tr("Mainstrings", "world_boss.second_bullet") }
    /// You can continue with normal Quest Bosses, damage will apply to both
    public static var thirdBullet: String { return L10n.tr("Mainstrings", "world_boss.third_bullet") }
    /// The %@ attacks!
    public static func title(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "world_boss.title", p1)
    }
    /// World Boss
    public static var worldBoss: String { return L10n.tr("Mainstrings", "world_boss.world_boss") }
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    var format = NSLocalizedString(key, tableName: table, bundle: bundle ?? Bundle(for: BundleToken.self), comment: "")
    let value = String(format: format, locale: Locale.current, arguments: args)
    if value != key || NSLocale.preferredLanguages.first == "en" {
        return value
    }
    // Fall back to en
    guard
        let path = Bundle.main.path(forResource: "Base", ofType: "lproj"),
        let bundle = Bundle(path: path)
        else { return value }
    format = bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
