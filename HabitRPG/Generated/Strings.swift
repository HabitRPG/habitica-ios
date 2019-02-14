// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
public enum L10n {
  /// Abort
  public static let abort = L10n.tr("Mainstrings", "abort")
  /// About
  public static let aboutText = L10n.tr("Mainstrings", "aboutText")
  /// Accept
  public static let accept = L10n.tr("Mainstrings", "accept")
  /// Active
  public static let active = L10n.tr("Mainstrings", "active")
  /// Active on %@
  public static func activeOn(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "active_on", p1)
  }
  /// I agree to follow the guidelines
  public static let agreeGuidelinesPrompt = L10n.tr("Mainstrings", "agree_guidelines_prompt")
  /// All
  public static let all = L10n.tr("Mainstrings", "all")
  /// Allocated
  public static let allocated = L10n.tr("Mainstrings", "allocated")
  /// Animal Ears
  public static let animalEars = L10n.tr("Mainstrings", "animal_ears")
  /// API Key
  public static let apiKey = L10n.tr("Mainstrings", "api_key")
  /// Back
  public static let back = L10n.tr("Mainstrings", "back")
  /// Bangs
  public static let bangs = L10n.tr("Mainstrings", "bangs")
  /// Body Size
  public static let bodySize = L10n.tr("Mainstrings", "body_size")
  /// Broad
  public static let broad = L10n.tr("Mainstrings", "broad")
  /// Buffs
  public static let buffs = L10n.tr("Mainstrings", "buffs")
  /// buy
  public static let buy = L10n.tr("Mainstrings", "buy")
  /// Buy All
  public static let buyAll = L10n.tr("Mainstrings", "buy_all")
  /// Buy for %@
  public static func buyForX(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "buy_for_x", p1)
  }
  /// Cancel
  public static let cancel = L10n.tr("Mainstrings", "cancel")
  /// Change
  public static let change = L10n.tr("Mainstrings", "change")
  /// Character Level
  public static let characterLevel = L10n.tr("Mainstrings", "character_level")
  /// Chat
  public static let chat = L10n.tr("Mainstrings", "chat")
  /// Check off any Dailies you did yesterday:
  public static let checkinYesterdaysDalies = L10n.tr("Mainstrings", "checkin_yesterdays_dalies")
  /// Choose Task
  public static let chooseTask = L10n.tr("Mainstrings", "choose_task")
  /// Clear
  public static let clear = L10n.tr("Mainstrings", "clear")
  /// Close
  public static let close = L10n.tr("Mainstrings", "close")
  /// Collect
  public static let collect = L10n.tr("Mainstrings", "collect")
  /// Color
  public static let color = L10n.tr("Mainstrings", "color")
  /// Complete
  public static let complete = L10n.tr("Mainstrings", "complete")
  /// Confirm
  public static let confirm = L10n.tr("Mainstrings", "confirm")
  /// Confirm Username
  public static let confirmUsername = L10n.tr("Mainstrings", "confirm_username")
  /// Continue
  public static let `continue` = L10n.tr("Mainstrings", "continue")
  /// Controls
  public static let controls = L10n.tr("Mainstrings", "controls")
  /// Copied Message
  public static let copiedMessage = L10n.tr("Mainstrings", "copied_message")
  /// Copied to Clipboard
  public static let copiedToClipboard = L10n.tr("Mainstrings", "copied_to_clipboard")
  /// Create
  public static let create = L10n.tr("Mainstrings", "create")
  /// Create Tag
  public static let createTag = L10n.tr("Mainstrings", "create_tag")
  /// Daily
  public static let daily = L10n.tr("Mainstrings", "daily")
  /// Damage Paused
  public static let damagePaused = L10n.tr("Mainstrings", "damage_paused")
  /// Dated
  public static let dated = L10n.tr("Mainstrings", "dated")
  /// 21-Day Streaks
  public static let dayStreaks = L10n.tr("Mainstrings", "day_streaks")
  /// days
  public static let days = L10n.tr("Mainstrings", "days")
  /// Delete
  public static let delete = L10n.tr("Mainstrings", "delete")
  /// Delete Tasks
  public static let deleteTasks = L10n.tr("Mainstrings", "delete_tasks")
  /// Description
  public static let description = L10n.tr("Mainstrings", "description")
  /// Details
  public static let details = L10n.tr("Mainstrings", "details")
  /// Difficulty
  public static let difficulty = L10n.tr("Mainstrings", "difficulty")
  /// Discover
  public static let discover = L10n.tr("Mainstrings", "discover")
  /// Display name
  public static let displayName = L10n.tr("Mainstrings", "display_name")
  /// Done
  public static let done = L10n.tr("Mainstrings", "done")
  /// Due
  public static let due = L10n.tr("Mainstrings", "due")
  /// I earned a new achievement in Habitica! 
  public static let earnedAchievementShare = L10n.tr("Mainstrings", "earned_achievement_share")
  /// Edit
  public static let edit = L10n.tr("Mainstrings", "edit")
  /// Edit Tag
  public static let editTag = L10n.tr("Mainstrings", "edit_tag")
  /// Eggs
  public static let eggs = L10n.tr("Mainstrings", "eggs")
  /// Email
  public static let email = L10n.tr("Mainstrings", "email")
  /// End Challenge
  public static let endChallenge = L10n.tr("Mainstrings", "end_challenge")
  /// Equip
  public static let equip = L10n.tr("Mainstrings", "equip")
  /// Experience
  public static let experience = L10n.tr("Mainstrings", "experience")
  /// Filter
  public static let filter = L10n.tr("Mainstrings", "filter")
  /// Filter by Tags
  public static let filterByTags = L10n.tr("Mainstrings", "filter_by_tags")
  /// Finish
  public static let finish = L10n.tr("Mainstrings", "finish")
  /// Flower
  public static let flower = L10n.tr("Mainstrings", "flower")
  /// Food
  public static let food = L10n.tr("Mainstrings", "food")
  /// Force Start
  public static let forceStart = L10n.tr("Mainstrings", "force_start")
  /// Friday
  public static let friday = L10n.tr("Mainstrings", "friday")
  /// Gems allow you to buy fun extras for your account, including:
  public static let gemBenefitsTitle = L10n.tr("Mainstrings", "gem_benefits_title")
  /// %d Gem cap
  public static func gemCap(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "gem_cap", p1)
  }
  /// Gems
  public static let gems = L10n.tr("Mainstrings", "gems")
  /// Buying gems supports the developers\nand helps keep Habitica running
  public static let gemsSupportDevelopers = L10n.tr("Mainstrings", "gems_support_developers")
  /// You sent %@ a %@-month Habitica subscription.
  public static func giftConfirmationBody(_ p1: String, _ p2: String) -> String {
    return L10n.tr("Mainstrings", "gift_confirmation_body", p1, p2)
  }
  /// You sent %@ a %@-month Habitica subscription and the same subscription was applied to your account for our Gift One Get One promotion!
  public static func giftConfirmationBodyG1g1(_ p1: String, _ p2: String) -> String {
    return L10n.tr("Mainstrings", "gift_confirmation_body_g1g1", p1, p2)
  }
  /// Your gift was sent!
  public static let giftConfirmationTitle = L10n.tr("Mainstrings", "gift_confirmation_title")
  /// While this promotion is active, you’ll receive a matching subscription automatically after sending your gift.
  public static let giftOneGetOneDescription = L10n.tr("Mainstrings", "gift_one_get_one_description")
  /// Gift one, Get one!
  public static let giftOneGetOneTitle = L10n.tr("Mainstrings", "gift_one_get_one_title")
  /// Enter recipient's @ username
  public static let giftRecipientSubtitle = L10n.tr("Mainstrings", "gift_recipient_subtitle")
  /// Who would you like to gift to?
  public static let giftRecipientTitle = L10n.tr("Mainstrings", "gift_recipient_title")
  /// Choose the subscription you’d like to gift below! This purchase won’t automatically renew.
  public static let giftSubscriptionPrompt = L10n.tr("Mainstrings", "gift_subscription_prompt")
  /// Glasses
  public static let glasses = L10n.tr("Mainstrings", "glasses")
  /// Gold
  public static let gold = L10n.tr("Mainstrings", "gold")
  /// Great
  public static let great = L10n.tr("Mainstrings", "great")
  /// Grey
  public static let grey = L10n.tr("Mainstrings", "grey")
  /// Group By
  public static let groupBy = L10n.tr("Mainstrings", "group_by")
  /// Hatch egg
  public static let hatchEgg = L10n.tr("Mainstrings", "hatch_egg")
  /// Hatch with potion
  public static let hatchPotion = L10n.tr("Mainstrings", "hatch_potion")
  /// Hatching Potions
  public static let hatchingPotions = L10n.tr("Mainstrings", "hatching_potions")
  /// Headband
  public static let headband = L10n.tr("Mainstrings", "headband")
  /// Health
  public static let health = L10n.tr("Mainstrings", "health")
  /// +%d Mystic Hourglass
  public static func hourglassCount(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "hourglass_count", p1)
  }
  /// Inactive
  public static let inactive = L10n.tr("Mainstrings", "inactive")
  /// You have to specify a valid Habitica Username as recipient.
  public static let invalidRecipientMessage = L10n.tr("Mainstrings", "invalid_recipient_message")
  /// Invalid Habitica Username
  public static let invalidRecipientTitle = L10n.tr("Mainstrings", "invalid_recipient_title")
  /// Invitations
  public static let invitations = L10n.tr("Mainstrings", "invitations")
  /// Invite Party
  public static let inviteParty = L10n.tr("Mainstrings", "invite_party")
  /// Join
  public static let join = L10n.tr("Mainstrings", "join")
  /// Join Challenge
  public static let joinChallenge = L10n.tr("Mainstrings", "join_challenge")
  /// Keep Tasks
  public static let keepTasks = L10n.tr("Mainstrings", "keep_tasks")
  /// Last Activity %@
  public static func lastActivity(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "last_activity", p1)
  }
  /// Leader
  public static let leader = L10n.tr("Mainstrings", "leader")
  /// Leave
  public static let leave = L10n.tr("Mainstrings", "leave")
  /// Leave Challenge
  public static let leaveChallenge = L10n.tr("Mainstrings", "leave_challenge")
  /// Do you want to leave the challenge and keep or delete the tasks?
  public static let leaveChallengePrompt = L10n.tr("Mainstrings", "leave_challenge_prompt")
  /// Leave Challenge?
  public static let leaveChallengeTitle = L10n.tr("Mainstrings", "leave_challenge_title")
  /// Level
  public static let level = L10n.tr("Mainstrings", "level")
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
  public static let levelupTitle = L10n.tr("Mainstrings", "levelup_title")
  /// Mana
  public static let mana = L10n.tr("Mainstrings", "mana")
  /// Mana Points
  public static let manaPoints = L10n.tr("Mainstrings", "mana_points")
  /// Menu
  public static let menu = L10n.tr("Mainstrings", "menu")
  /// Moderator
  public static let moderator = L10n.tr("Mainstrings", "moderator")
  /// Monday
  public static let monday = L10n.tr("Mainstrings", "monday")
  /// Monthly
  public static let monthly = L10n.tr("Mainstrings", "monthly")
  /// Monthly Gem Cap Reached
  public static let monthlyGemCapReached = L10n.tr("Mainstrings", "monthly_gem_cap_reached")
  /// months
  public static let months = L10n.tr("Mainstrings", "months")
  /// Mounts
  public static let mounts = L10n.tr("Mainstrings", "mounts")
  /// My Challenges
  public static let myChallenges = L10n.tr("Mainstrings", "my_challenges")
  /// My Guilds
  public static let myGuilds = L10n.tr("Mainstrings", "my_guilds")
  /// Mystery Sets
  public static let mysterySets = L10n.tr("Mainstrings", "mystery_sets")
  /// Name
  public static let name = L10n.tr("Mainstrings", "name")
  /// Never
  public static let never = L10n.tr("Mainstrings", "never")
  /// Next
  public static let next = L10n.tr("Mainstrings", "next")
  /// Your next prize unlocks in 1 Check-In.
  public static let nextCheckinPrize1Day = L10n.tr("Mainstrings", "next_checkin_prize_1_day")
  /// Your next prize unlocks in %d Check-Ins
  public static func nextCheckinPrizeXDays(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "next_checkin_prize_x_days", p1)
  }
  /// No Benefit
  public static let noBenefit = L10n.tr("Mainstrings", "no_benefit")
  /// No Camera available
  public static let noCamera = L10n.tr("Mainstrings", "no_camera")
  /// no days
  public static let noDays = L10n.tr("Mainstrings", "no_days")
  /// Not enough Gems
  public static let notEnoughGems = L10n.tr("Mainstrings", "not_enough_gems")
  /// Not enough Gold
  public static let notEnoughGold = L10n.tr("Mainstrings", "not_enough_gold")
  /// Not enough Hourglasses
  public static let notEnoughHourglasses = L10n.tr("Mainstrings", "not_enough_hourglasses")
  /// Not getting the right drops? Check out the Market to buy just the things you need!
  public static let notGettingDrops = L10n.tr("Mainstrings", "not_getting_drops")
  /// Notes
  public static let notes = L10n.tr("Mainstrings", "notes")
  /// OK
  public static let ok = L10n.tr("Mainstrings", "ok")
  /// 1 Filter
  public static let oneFilter = L10n.tr("Mainstrings", "one_filter")
  /// 1 Month
  public static let oneMonth = L10n.tr("Mainstrings", "one_month")
  /// Open
  public static let `open` = L10n.tr("Mainstrings", "open")
  /// Open App Store Page
  public static let openAppStore = L10n.tr("Mainstrings", "open_app_store")
  /// Open iTunes
  public static let openItunes = L10n.tr("Mainstrings", "open_itunes")
  /// Open Habitica Website
  public static let openWebsite = L10n.tr("Mainstrings", "open_website")
  /// Password
  public static let password = L10n.tr("Mainstrings", "password")
  /// Pause Damage
  public static let pauseDamage = L10n.tr("Mainstrings", "pause_damage")
  /// Pending damage
  public static let pendingDamage = L10n.tr("Mainstrings", "pending_damage")
  /// Pets
  public static let pets = L10n.tr("Mainstrings", "pets")
  /// Photo URL
  public static let photoUrl = L10n.tr("Mainstrings", "photo_url")
  /// Pin to Rewards
  public static let pinToRewards = L10n.tr("Mainstrings", "pin_to_rewards")
  /// Plain Backgrounds
  public static let plainBackgrounds = L10n.tr("Mainstrings", "plain_backgrounds")
  /// Ponytail
  public static let ponytail = L10n.tr("Mainstrings", "ponytail")
  /// Publish Challenge
  public static let publishChallenge = L10n.tr("Mainstrings", "publish_challenge")
  /// Purchase for %d Gems
  public static func purchaseForGems(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "purchase_for_gems", p1)
  }
  /// Purchase Gems
  public static let purchaseGems = L10n.tr("Mainstrings", "purchase_gems")
  /// You purchased %@
  public static func purchased(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "purchased", p1)
  }
  /// The scanned QR-Code did not contain a valid Habitica User ID.
  public static let qrInvalidIdMessage = L10n.tr("Mainstrings", "qr_invalid_id_message")
  /// Invalid Habitica User ID
  public static let qrInvalidIdTitle = L10n.tr("Mainstrings", "qr_invalid_id_title")
  /// Quests
  public static let quests = L10n.tr("Mainstrings", "quests")
  /// Rage Meter
  public static let rageMeter = L10n.tr("Mainstrings", "rage_meter")
  /// Randomize
  public static let randomize = L10n.tr("Mainstrings", "randomize")
  /// You open the box and receive %@
  public static func receivedMysteryItem(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "received_mystery_item", p1)
  }
  /// Recipient
  public static let recipient = L10n.tr("Mainstrings", "recipient")
  /// Reject
  public static let reject = L10n.tr("Mainstrings", "reject")
  /// Remember to check off your Dailies!
  public static let rememberCheckOffDailies = L10n.tr("Mainstrings", "remember_check_off_dailies")
  /// Reminder
  public static let reminder = L10n.tr("Mainstrings", "reminder")
  /// Repeat Password
  public static let repeatPassword = L10n.tr("Mainstrings", "repeat_password")
  /// Reply
  public static let reply = L10n.tr("Mainstrings", "reply")
  /// Report %@ for violation?
  public static func reportXViolation(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "report_x_violation", p1)
  }
  /// Reset Justins Tips
  public static let resetTips = L10n.tr("Mainstrings", "reset_tips")
  /// Reset Streak
  public static let resetStreak = L10n.tr("Mainstrings", "resetStreak")
  /// Resume Damage
  public static let resumeDamage = L10n.tr("Mainstrings", "resume_damage")
  /// Resync
  public static let resync = L10n.tr("Mainstrings", "resync")
  /// Resync all
  public static let resyncAll = L10n.tr("Mainstrings", "resync_all")
  /// Resync this task
  public static let resyncTask = L10n.tr("Mainstrings", "resync_task")
  /// Saturday
  public static let saturday = L10n.tr("Mainstrings", "saturday")
  /// Save
  public static let save = L10n.tr("Mainstrings", "save")
  /// Scan QR Code
  public static let scanQRCode = L10n.tr("Mainstrings", "scan_QR_code")
  /// Search
  public static let search = L10n.tr("Mainstrings", "search")
  /// Sell for %d gold
  public static func sell(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "sell", p1)
  }
  /// Send
  public static let send = L10n.tr("Mainstrings", "send")
  /// Send Gift
  public static let sendGift = L10n.tr("Mainstrings", "send_gift")
  /// Share
  public static let share = L10n.tr("Mainstrings", "share")
  /// Shirt
  public static let shirt = L10n.tr("Mainstrings", "shirt")
  /// Size
  public static let size = L10n.tr("Mainstrings", "size")
  /// Skip
  public static let skip = L10n.tr("Mainstrings", "skip")
  /// Slim
  public static let slim = L10n.tr("Mainstrings", "slim")
  /// Special Items
  public static let specialItems = L10n.tr("Mainstrings", "specialItems")
  /// Staff
  public static let staff = L10n.tr("Mainstrings", "staff")
  /// Start my day
  public static let startMyDay = L10n.tr("Mainstrings", "start_my_day")
  /// You've completed your Daily for 21 days in a row! Amazing job. Don't break the streak!
  public static let streakAchievementDescription = L10n.tr("Mainstrings", "streak_achievement_description")
  /// You earned a streak achievement!
  public static let streakAchievementTitle = L10n.tr("Mainstrings", "streak_achievement_title")
  /// Strong
  public static let strong = L10n.tr("Mainstrings", "strong")
  /// Subscribe
  public static let subscribe = L10n.tr("Mainstrings", "subscribe")
  /// Subscribe for Hourglasses
  public static let subscribeForHourglasses = L10n.tr("Mainstrings", "subscribe_for_hourglasses")
  /// Subscription
  public static let subscription = L10n.tr("Mainstrings", "subscription")
  /// Become a subscriber and you’ll get these useful benefits:
  public static let subscriptionBenefitsTitle = L10n.tr("Mainstrings", "subscription_benefits_title")
  /// Gift a Subscription
  public static let subscriptionGiftButton = L10n.tr("Mainstrings", "subscription_gift_button")
  /// Want to give the benefits of a subscription to someone else?
  public static let subscriptionGiftExplanation = L10n.tr("Mainstrings", "subscription_gift_explanation")
  /// Alexander the Merchant will sell you Gems at a cost of 20 gold per gem. His monthly shipments are initially capped at 25 Gems per month, but this cap increases by 5 Gems for every three months of consecutive subscription, up to a maximum of 50 Gems per month!
  public static let subscriptionInfo1Description = L10n.tr("Mainstrings", "subscription_info_1_description")
  /// Buy gems with gold
  public static let subscriptionInfo1Title = L10n.tr("Mainstrings", "subscription_info_1_title")
  /// Each month you will receive a unique cosmetic item for your avatar!\n\nPlus, for every three months of consecutive subscription, the Mysterious Time Travelers will grant you access to historic (and futuristic!) cosmetic items.
  public static let subscriptionInfo2Description = L10n.tr("Mainstrings", "subscription_info_2_description")
  /// Exclusive monthly items
  public static let subscriptionInfo2Title = L10n.tr("Mainstrings", "subscription_info_2_title")
  /// Makes completed To-Dos and task history available for longer.
  public static let subscriptionInfo3Description = L10n.tr("Mainstrings", "subscription_info_3_description")
  /// Retain additional history entries
  public static let subscriptionInfo3Title = L10n.tr("Mainstrings", "subscription_info_3_title")
  /// Double drop caps will let you receive more items from your completed tasks every day, helping you complete your stable faster!
  public static let subscriptionInfo4Description = L10n.tr("Mainstrings", "subscription_info_4_description")
  /// Daily drop-caps doubled
  public static let subscriptionInfo4Title = L10n.tr("Mainstrings", "subscription_info_4_title")
  /// Subscribing supports the developers\nand helps keep Habitica running
  public static let subscriptionSupportDevelopers = L10n.tr("Mainstrings", "subscription_support_developers")
  /// success
  public static let success = L10n.tr("Mainstrings", "success")
  /// Summary
  public static let summary = L10n.tr("Mainstrings", "summary")
  /// Sunday
  public static let sunday = L10n.tr("Mainstrings", "sunday")
  /// Tags
  public static let tags = L10n.tr("Mainstrings", "tags")
  /// Take me back
  public static let takeMeBack = L10n.tr("Mainstrings", "take_me_back")
  /// Tap to Show
  public static let tapToShow = L10n.tr("Mainstrings", "tap_to_show")
  /// Welcome to the Inn! Pull up a chair to chat, or take a break from your tasks.
  public static let tavernIntroHeader = L10n.tr("Mainstrings", "tavern_intro_header")
  /// Teleporting to Habitica
  public static let teleportingHabitica = L10n.tr("Mainstrings", "teleporting_habitica")
  /// Thursday
  public static let thursday = L10n.tr("Mainstrings", "thursday")
  /// Title
  public static let title = L10n.tr("Mainstrings", "title")
  /// Tuesday
  public static let tuesday = L10n.tr("Mainstrings", "tuesday")
  /// Two-Handed
  public static let twoHanded = L10n.tr("Mainstrings", "twoHanded")
  /// Unequip
  public static let unequip = L10n.tr("Mainstrings", "unequip")
  /// You've unlocked the Drop System! Now when you complete tasks, you have a small chance of finding an item, including eggs, potions, and food!
  public static let unlockDropsDescription = L10n.tr("Mainstrings", "unlockDropsDescription")
  /// You unlocked the drop system!
  public static let unlockDropsTitle = L10n.tr("Mainstrings", "unlockDropsTitle")
  /// Unlocks at level 10
  public static let unlocksLevelTen = L10n.tr("Mainstrings", "unlocks_level_ten")
  /// Unlocks after selecting a class
  public static let unlocksSelectingClass = L10n.tr("Mainstrings", "unlocks_selecting_class")
  /// Unpin from Rewards
  public static let unpinFromRewards = L10n.tr("Mainstrings", "unpin_from_rewards")
  /// No longer want to subscribe? You can manage your subscription from iTunes.
  public static let unsubscribeItunes = L10n.tr("Mainstrings", "unsubscribe_itunes")
  /// No longer want to subscribe? Due to your payment method, you can only unsubscribe through the website.
  public static let unsubscribeWebsite = L10n.tr("Mainstrings", "unsubscribe_website")
  /// Use
  public static let use = L10n.tr("Mainstrings", "use")
  /// User ID
  public static let userID = L10n.tr("Mainstrings", "userID")
  /// Username
  public static let username = L10n.tr("Mainstrings", "username")
  /// Your username was confirmed
  public static let usernameConfirmedToast = L10n.tr("Mainstrings", "username_confirmed_toast")
  /// Your display name hasn’t changed but your old login name will now be your username used for invitations, chat @mentions, and messaging.
  public static let usernamePromptBody = L10n.tr("Mainstrings", "username_prompt_body")
  /// Usernames should conform to our #<ts>Terms of Service# and #<cg>Community Guidelines#. If you didn’t previously set a login name, your username was auto-generated.
  public static let usernamePromptDisclaimer = L10n.tr("Mainstrings", "username_prompt_disclaimer")
  /// It’s time to set your username!
  public static let usernamePromptTitle = L10n.tr("Mainstrings", "username_prompt_title")
  /// If you’d like to learn more about this change, #<wk>visit our wiki.#
  public static let usernamePromptWiki = L10n.tr("Mainstrings", "username_prompt_wiki")
  /// Invitation was sent to users.
  public static let usersInvited = L10n.tr("Mainstrings", "users_invited")
  /// View Participant Progress
  public static let viewParticipantProgress = L10n.tr("Mainstrings", "view_participant_progress")
  /// Weak
  public static let `weak` = L10n.tr("Mainstrings", "weak")
  /// Wednesday
  public static let wednesday = L10n.tr("Mainstrings", "wednesday")
  /// Weekly
  public static let weekly = L10n.tr("Mainstrings", "weekly")
  /// weeks
  public static let weeks = L10n.tr("Mainstrings", "weeks")
  /// Wecome Back!
  public static let welcomeBack = L10n.tr("Mainstrings", "welcome_back")
  /// What's a World Boss?
  public static let whatsWorldBoss = L10n.tr("Mainstrings", "whats_world_boss")
  /// Wheelchair
  public static let wheelchair = L10n.tr("Mainstrings", "wheelchair")
  /// Oh dear, pay no heed to the monster below -- this is still a safe haven to chat on your breaks.
  public static let worldBossIntroHeader = L10n.tr("Mainstrings", "world_boss_intro_header")
  /// Write a Message
  public static let writeAMessage = L10n.tr("Mainstrings", "write_a_message")
  /// Write Message
  public static let writeMessage = L10n.tr("Mainstrings", "write_message")
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
  public static let yearly = L10n.tr("Mainstrings", "yearly")
  /// years
  public static let years = L10n.tr("Mainstrings", "years")
  /// Your balance:
  public static let yourBalance = L10n.tr("Mainstrings", "your_balance")

  public enum NPCs {
    /// Alex the Merchant
    public static let alex = L10n.tr("Mainstrings", "NPCs.alex")
    /// Daniel the inn keeper
    public static let daniel = L10n.tr("Mainstrings", "NPCs.daniel")
    /// Ian the Quest Guide
    public static let ian = L10n.tr("Mainstrings", "NPCs.ian")
    /// Matt the beast master
    public static let matt = L10n.tr("Mainstrings", "NPCs.matt")
    /// Seasonal Sorceress
    public static let seasonalSorceress = L10n.tr("Mainstrings", "NPCs.seasonalSorceress")
  }

  public enum About {
    /// Acknowledgements
    public static let acknowledgements = L10n.tr("Mainstrings", "about.acknowledgements")
    /// Export Database
    public static let exportDatabase = L10n.tr("Mainstrings", "about.export_database")
    /// Leave Review
    public static let leaveReview = L10n.tr("Mainstrings", "about.leave_review")
    /// Web love open source software.
    public static let loveOpenSource = L10n.tr("Mainstrings", "about.love_open_source")
    /// Whoops, looks like you haven't set up your email on this phone yet. Configure an account in the iOS mail app to use this quick-reporting option, or just email us directly at %@
    public static func noEmailMessage(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "about.no_email_message", p1)
    }
    /// Your email isn't set up yet
    public static let noEmailTitle = L10n.tr("Mainstrings", "about.no_email_title")
    /// Report a Bug
    public static let reportBug = L10n.tr("Mainstrings", "about.report_bug")
    /// Send Feedback
    public static let sendFeedback = L10n.tr("Mainstrings", "about.send_feedback")
    /// Version
    public static let version = L10n.tr("Mainstrings", "about.version")
    /// View Source Code
    public static let viewSourceCode = L10n.tr("Mainstrings", "about.view_source_code")
    /// Website
    public static let website = L10n.tr("Mainstrings", "about.website")
  }

  public enum Accessibility {
    /// Collapse Checklist
    public static let collapseChecklist = L10n.tr("Mainstrings", "accessibility.collapse_checklist")
    /// Complete Task
    public static let completeTask = L10n.tr("Mainstrings", "accessibility.complete_task")
    /// Completed
    public static let completed = L10n.tr("Mainstrings", "accessibility.completed")
    /// Completed %@
    public static func completedX(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "accessibility.completed_x", p1)
    }
    /// Copy Message
    public static let copyMessage = L10n.tr("Mainstrings", "accessibility.copy_message")
    /// Delete Message
    public static let deleteMessage = L10n.tr("Mainstrings", "accessibility.delete_message")
    /// Double tap to complete
    public static let doubleTapToComplete = L10n.tr("Mainstrings", "accessibility.double_tap_to_complete")
    /// Double tap to edit
    public static let doubleTapToEdit = L10n.tr("Mainstrings", "accessibility.double_tap_to_edit")
    /// Due
    public static let due = L10n.tr("Mainstrings", "accessibility.due")
    /// Expand Checklist
    public static let expandChecklist = L10n.tr("Mainstrings", "accessibility.expand_checklist")
    /// Like Message
    public static let likeMessage = L10n.tr("Mainstrings", "accessibility.like_message")
    /// Not Completed
    public static let notCompleted = L10n.tr("Mainstrings", "accessibility.not_completed")
    /// Not Completed %@
    public static func notCompletedX(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "accessibility.not_completed_x", p1)
    }
    /// Not Due
    public static let notDue = L10n.tr("Mainstrings", "accessibility.not_due")
    /// Reply to Message
    public static let replyToMessage = L10n.tr("Mainstrings", "accessibility.reply_to_message")
    /// Report Message
    public static let reportMessage = L10n.tr("Mainstrings", "accessibility.report_message")
    /// Score Habit Down
    public static let scoreHabitDown = L10n.tr("Mainstrings", "accessibility.score_habit_down")
    /// Score Habit Up
    public static let scoreHabitUp = L10n.tr("Mainstrings", "accessibility.score_habit_up")
    /// Double tap to hide boss art
    public static let tapHideBossArt = L10n.tr("Mainstrings", "accessibility.tap_hide_boss_art")
    /// %@, World Boss, pending damage: %@
    public static func worldBossPendingDamage(_ p1: String, _ p2: String) -> String {
      return L10n.tr("Mainstrings", "accessibility.world_boss_pending_damage", p1, p2)
    }
  }

  public enum Avatar {
    /// Background
    public static let background = L10n.tr("Mainstrings", "avatar.background")
    /// Bangs
    public static let bangs = L10n.tr("Mainstrings", "avatar.bangs")
    /// Beard
    public static let beard = L10n.tr("Mainstrings", "avatar.beard")
    /// Body
    public static let body = L10n.tr("Mainstrings", "avatar.body")
    /// Extras
    public static let extras = L10n.tr("Mainstrings", "avatar.extras")
    /// Flower
    public static let flower = L10n.tr("Mainstrings", "avatar.flower")
    /// Glasses
    public static let glasses = L10n.tr("Mainstrings", "avatar.glasses")
    /// Hair
    public static let hair = L10n.tr("Mainstrings", "avatar.hair")
    /// Hair Style
    public static let hairStyle = L10n.tr("Mainstrings", "avatar.hair_style")
    /// Hair Color
    public static let hairColor = L10n.tr("Mainstrings", "avatar.hairColor")
    /// Head
    public static let head = L10n.tr("Mainstrings", "avatar.head")
    /// Mustache
    public static let mustache = L10n.tr("Mainstrings", "avatar.mustache")
    /// Shirt
    public static let shirt = L10n.tr("Mainstrings", "avatar.shirt")
    /// Skin
    public static let skin = L10n.tr("Mainstrings", "avatar.skin")
    /// Skin Color
    public static let skinColor = L10n.tr("Mainstrings", "avatar.skin_color")
    /// Wheelchair
    public static let wheelchair = L10n.tr("Mainstrings", "avatar.wheelchair")
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
    public static let healer = L10n.tr("Mainstrings", "classes.healer")
    /// Healers stand impervious against harm, and extend that protection to others. Missed Dailies and bad Habits don't faze them much, and they have ways to recover Health from failure. Play a Healer if you enjoy assisting others in your Party, or if the idea of cheating Death through hard work inspires you!
    public static let healerDescription = L10n.tr("Mainstrings", "classes.healer_description")
    /// Mage
    public static let mage = L10n.tr("Mainstrings", "classes.mage")
    /// Mages learn swiftly, gaining Experience and Levels faster than other classes. They also get a great deal of Mana for using special abilities. Play a Mage if you enjoy the tactical game aspects of Habitica, or if you are strongly motivated by leveling up and unlocking advanced features! 
    public static let mageDescription = L10n.tr("Mainstrings", "classes.mage_description")
    /// Rogue
    public static let rogue = L10n.tr("Mainstrings", "classes.rogue")
    /// Rogues love to accumulate wealth, gaining more Gold than anyone else, and are adept at finding random items. Their iconic Stealth ability lets them duck the consequences of missed Dailies. Play a Rogue if you find strong motivation from Rewards and Achievements, striving for loot and badges!
    public static let rogueDescription = L10n.tr("Mainstrings", "classes.rogue_description")
    /// Warrior
    public static let warrior = L10n.tr("Mainstrings", "classes.warrior")
    /// Warriors score more and better "critical hits", which randomly give bonus Gold, Experience, and drop chance for scoring a task. They also deal heavy damage to boss monsters. Play a Warrior if you find motivation from unpredictable jackpot-style rewards, or want to dish out the hurt in boss Quests!
    public static let warriorDescription = L10n.tr("Mainstrings", "classes.warrior_description")
  }

  public enum Equipment {
    /// Armor
    public static let armor = L10n.tr("Mainstrings", "equipment.armor")
    /// Auto-Equip new
    public static let autoEquip = L10n.tr("Mainstrings", "equipment.auto_equip")
    /// Back Accessory
    public static let back = L10n.tr("Mainstrings", "equipment.back")
    /// Battle Gear
    public static let battleGear = L10n.tr("Mainstrings", "equipment.battle_gear")
    /// Body Accessory
    public static let body = L10n.tr("Mainstrings", "equipment.body")
    /// Class Equipment
    public static let classEquipment = L10n.tr("Mainstrings", "equipment.class_equipment")
    /// Costume
    public static let costume = L10n.tr("Mainstrings", "equipment.costume")
    /// Select "Use Costume" to equip items to your avatar without affecting the Stats from your Battle Gear! This means that you can dress up your avatar in whatever outfit you like while still having your best Battle Gear equipped.
    public static let costumeExplanation = L10n.tr("Mainstrings", "equipment.costume_explanation")
    /// Equipment
    public static let equipment = L10n.tr("Mainstrings", "equipment.equipment")
    /// Eyewear
    public static let eyewear = L10n.tr("Mainstrings", "equipment.eyewear")
    /// Head Gear
    public static let head = L10n.tr("Mainstrings", "equipment.head")
    /// Head Accessory
    public static let headAccessory = L10n.tr("Mainstrings", "equipment.head_accessory")
    /// Nothing Equipped
    public static let nothingEquipped = L10n.tr("Mainstrings", "equipment.nothing_equipped")
    /// Off-Hand
    public static let offHand = L10n.tr("Mainstrings", "equipment.off_hand")
    /// Use Costume
    public static let useCostume = L10n.tr("Mainstrings", "equipment.use_costume")
    /// Weapon
    public static let weapon = L10n.tr("Mainstrings", "equipment.weapon")
  }

  public enum Errors {
    /// Error
    public static let error = L10n.tr("Mainstrings", "errors.error")
    /// There was an error accepting the quest invitation
    public static let questInviteAccept = L10n.tr("Mainstrings", "errors.quest_invite_accept")
    /// There was an error rejecting the quest invitation
    public static let questInviteReject = L10n.tr("Mainstrings", "errors.quest_invite_reject")
    /// Your message could not be sent.
    public static let reply = L10n.tr("Mainstrings", "errors.reply")
    /// There was an error with your request: %@
    public static func request(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "errors.request", p1)
    }
    /// Sync Error
    public static let sync = L10n.tr("Mainstrings", "errors.sync")
    /// There was an error syncing some changes.
    public static let syncMessage = L10n.tr("Mainstrings", "errors.sync_message")
  }

  public enum Faint {
    /// Refill Health & Try Again
    public static let button = L10n.tr("Mainstrings", "faint.button")
    /// You lost a Level, your Gold, and a piece of Equipment, but you can get them all back with hard work!
    public static let description = L10n.tr("Mainstrings", "faint.description")
    /// Don't despair!
    public static let dontDespair = L10n.tr("Mainstrings", "faint.dont_despair")
    /// Good luck--you'll do great.
    public static let goodLuck = L10n.tr("Mainstrings", "faint.good_luck")
    /// You ran out of Health!
    public static let title = L10n.tr("Mainstrings", "faint.title")
  }

  public enum Groups {
    /// Assign new Leader
    public static let assignNewLeader = L10n.tr("Mainstrings", "groups.assign_new_leader")
    /// Name may not be empty.
    public static let errorNameRequired = L10n.tr("Mainstrings", "groups.error_name_required")
    /// %@ invited you to join Guild: %@
    public static func guildInvitationInvitername(_ p1: String, _ p2: String) -> String {
      return L10n.tr("Mainstrings", "groups.guild_invitation_invitername", p1, p2)
    }
    /// Someone invited you to join Guild: %@
    public static func guildInvitationNoInvitername(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "groups.guild_invitation_no_invitername", p1)
    }
    /// Invite a Member
    public static let inviteMember = L10n.tr("Mainstrings", "groups.invite_member")
    /// Only leader can create Challenges
    public static let leaderChallenges = L10n.tr("Mainstrings", "groups.leader_challenges")
    /// Members
    public static let members = L10n.tr("Mainstrings", "groups.members")

    public enum Invite {
      /// Add an Email
      public static let addEmail = L10n.tr("Mainstrings", "groups.invite.add_email")
      /// Add a User ID
      public static let addUserid = L10n.tr("Mainstrings", "groups.invite.add_userid")
      /// Add a Username
      public static let addUsername = L10n.tr("Mainstrings", "groups.invite.add_username")
      /// Invitation Type
      public static let invitationType = L10n.tr("Mainstrings", "groups.invite.invitation_type")
    }
  }

  public enum Guilds {
    /// Guild Bank
    public static let guildBank = L10n.tr("Mainstrings", "guilds.guild_bank")
    /// Guild Challenges
    public static let guildChallenges = L10n.tr("Mainstrings", "guilds.guild_challenges")
    /// Guild Description
    public static let guildDescription = L10n.tr("Mainstrings", "guilds.guild_description")
    /// Guild Leader
    public static let guildLeader = L10n.tr("Mainstrings", "guilds.guild_leader")
    /// Guild Members
    public static let guildMembers = L10n.tr("Mainstrings", "guilds.guild_members")
    /// Invite to Guild
    public static let inviteToGuild = L10n.tr("Mainstrings", "guilds.invite_to_guild")
    /// Join Guilds
    public static let joinGuild = L10n.tr("Mainstrings", "guilds.join_guild")
    /// Keep challenges
    public static let keepChallenges = L10n.tr("Mainstrings", "guilds.keep_challenges")
    /// Leave Challenges
    public static let leaveChallenges = L10n.tr("Mainstrings", "guilds.leave_challenges")
    /// Do you want to leave the guild and keep or delete the challenges?
    public static let leaveGuildDescription = L10n.tr("Mainstrings", "guilds.leave_guild_description")
    /// Leave Guild?
    public static let leaveGuildTitle = L10n.tr("Mainstrings", "guilds.leave_guild_title")
  }

  public enum Intro {
    /// So how would you like to look? Don’t worry, you can change this later.
    public static let avatarSetupSpeechbubble = L10n.tr("Mainstrings", "intro.avatar_setup_speechbubble")
    /// Let's start!
    public static let letsGo = L10n.tr("Mainstrings", "intro.lets_go")
    /// Great! Now, what are you interested in working on throughout this journey?
    public static let taskSetupSpeechbubble = L10n.tr("Mainstrings", "intro.task_setup_speechbubble")
    /// What should we call you?
    public static let welcomePrompt = L10n.tr("Mainstrings", "intro.welcome_prompt")
    /// Oh, you must be new here. I’m Justin, your guide to Habitica.\n\nFirst, what should we call you? Feel free to change what I picked. When you’re all set, let’s create your avatar!
    public static let welcomeSpeechbubble = L10n.tr("Mainstrings", "intro.welcome_speechbubble")

    public enum Card1 {
      /// It’s time to have fun while you get things done. Join over 2 million others improving their life one task at a time.
      public static let text = L10n.tr("Mainstrings", "intro.card1.text")
      /// Welcome to
      public static let title = L10n.tr("Mainstrings", "intro.card1.title")
    }

    public enum Card2 {
      /// Progress in life
      public static let subtitle = L10n.tr("Mainstrings", "intro.card2.subtitle")
      /// Unlock features in the game by checking off your real life tasks. Earn armor, pets, and more as rewards for meeting your goals. 
      public static let text = L10n.tr("Mainstrings", "intro.card2.text")
      /// Progress in the game
      public static let title = L10n.tr("Mainstrings", "intro.card2.title")
    }

    public enum Card3 {
      /// Fight monsters
      public static let subtitle = L10n.tr("Mainstrings", "intro.card3.subtitle")
      /// Keep your goals on track with help from your friends. Support each other in life and in battle as you improve together!
      public static let text = L10n.tr("Mainstrings", "intro.card3.text")
      /// Get social
      public static let title = L10n.tr("Mainstrings", "intro.card3.title")
    }
  }

  public enum Inventory {
    /// Available Until %@
    public static func availableUntil(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "inventory.available_until", p1)
    }
    /// You hatched a new pet!
    public static let hatched = L10n.tr("Mainstrings", "inventory.hatched")
    /// I just hatched a %@ %@ pet in Habitica by completing my real-life tasks!
    public static func hatchedSharing(_ p1: String, _ p2: String) -> String {
      return L10n.tr("Mainstrings", "inventory.hatchedSharing", p1, p2)
    }
    /// No more Gems available this month. More become available within the first 3 days of each month.
    public static let noGemsLeft = L10n.tr("Mainstrings", "inventory.no_gems_left")
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
    public static let market = L10n.tr("Mainstrings", "locations.market")
    /// Quest Shop
    public static let questShop = L10n.tr("Mainstrings", "locations.quest_shop")
    /// Seasonal Shop
    public static let seasonalShop = L10n.tr("Mainstrings", "locations.seasonal_shop")
    /// Stable
    public static let stable = L10n.tr("Mainstrings", "locations.stable")
    /// Tavern
    public static let tavern = L10n.tr("Mainstrings", "locations.tavern")
  }

  public enum Login {
    /// There was an error with the authentication. Try again later
    public static let authenticationError = L10n.tr("Mainstrings", "login.authentication_error")
    /// Email a Password Reset Link
    public static let emailPasswordLink = L10n.tr("Mainstrings", "login.email_password_link")
    /// Email / Username
    public static let emailUsername = L10n.tr("Mainstrings", "login.email_username")
    /// Enter the email address you used to register your Habitica account.
    public static let enterEmail = L10n.tr("Mainstrings", "login.enter_email")
    /// Forgot Password
    public static let forgotPassword = L10n.tr("Mainstrings", "login.forgot_password")
    /// Login
    public static let login = L10n.tr("Mainstrings", "login.login")
    /// Login with Facebook
    public static let loginFacebook = L10n.tr("Mainstrings", "login.login_facebook")
    /// Login with Google
    public static let loginGoogle = L10n.tr("Mainstrings", "login.login_google")
    /// Password and password confirmation have to match.
    public static let passwordConfirmError = L10n.tr("Mainstrings", "login.password_confirm_error")
    /// Register
    public static let register = L10n.tr("Mainstrings", "login.register")
    /// If we have your email on file, instructions for setting a new password have been sent to your email.
    public static let resetPasswordResponse = L10n.tr("Mainstrings", "login.reset_password_response")
  }

  public enum Member {
    /// Last logged in
    public static let lastLoggedIn = L10n.tr("Mainstrings", "member.last_logged_in")
    /// Member Since
    public static let memberSince = L10n.tr("Mainstrings", "member.member_since")
  }

  public enum Menu {
    /// Cast Spells
    public static let castSpells = L10n.tr("Mainstrings", "menu.cast_spells")
    /// Customize Avatar
    public static let customizeAvatar = L10n.tr("Mainstrings", "menu.customize_avatar")
    /// Gems & Subscriptions
    public static let gemsSubscriptions = L10n.tr("Mainstrings", "menu.gems_subscriptions")
    /// Help & FAQ
    public static let helpFaq = L10n.tr("Mainstrings", "menu.help_faq")
    /// Inventory
    public static let inventory = L10n.tr("Mainstrings", "menu.inventory")
    /// Select Class
    public static let selectClass = L10n.tr("Mainstrings", "menu.select_class")
    /// Shops
    public static let shops = L10n.tr("Mainstrings", "menu.shops")
    /// Social
    public static let social = L10n.tr("Mainstrings", "menu.social")
    /// Use Skills
    public static let useSkills = L10n.tr("Mainstrings", "menu.use_skills")
  }

  public enum Party {
    /// Create a new Party
    public static let createPartyButton = L10n.tr("Mainstrings", "party.create_party_button")
    /// Take on quests with friends or on your own. Battle monsters, create Challenges, and help yourself stay accountable through Parties. 
    public static let createPartyDescription = L10n.tr("Mainstrings", "party.create_party_description")
    /// Play Habitica in a Party
    public static let createPartyTitle = L10n.tr("Mainstrings", "party.create_party_title")
    /// %@ invited you to join their party
    public static func invitationInvitername(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "party.invitation_invitername", p1)
    }
    /// Someone invited you to join their party
    public static let invitationNoInvitername = L10n.tr("Mainstrings", "party.invitation_no_invitername")
    /// %@ invited you to participate in a quest
    public static func invitedToQuest(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "party.invited_to_quest", p1)
    }
    /// Give a Party member the username found below and they can send you an invite
    public static let joinPartyDescription = L10n.tr("Mainstrings", "party.join_party_description")
    /// Want to join a party?
    public static let joinPartyTitle = L10n.tr("Mainstrings", "party.join_party_title")
    /// Party Challenges
    public static let partyChallenges = L10n.tr("Mainstrings", "party.party_challenges")
    /// Party Description
    public static let partyDescription = L10n.tr("Mainstrings", "party.party_description")
    /// %d/%d Members responded
    public static func questNumberResponded(_ p1: Int, _ p2: Int) -> String {
      return L10n.tr("Mainstrings", "party.quest_number_responded", p1, p2)
    }
    /// %d Participants
    public static func questParticipantCount(_ p1: Int) -> String {
      return L10n.tr("Mainstrings", "party.quest_participant_count", p1)
    }
    /// Start a Quest
    public static let startQuest = L10n.tr("Mainstrings", "party.start_quest")
  }

  public enum Quests {
    /// Accepted
    public static let accepted = L10n.tr("Mainstrings", "quests.accepted")
    /// Boss Battle
    public static let bossBattle = L10n.tr("Mainstrings", "quests.boss_battle")
    /// Collection quest
    public static let collectionQuest = L10n.tr("Mainstrings", "quests.collection_quest")
    /// Are you sure you want to abort this mission? It will abort it for everyone in your party and all progress will be lost. The quest scroll will be returned to the quest owner.
    public static let confirmAbort = L10n.tr("Mainstrings", "quests.confirm_abort")
    /// Are you sure you want to cancel this quest? All invitation acceptances will be lost. The quest owner will retain possession of the quest scroll.
    public static let confirmCancelInvitation = L10n.tr("Mainstrings", "quests.confirm_cancel_invitation")
    /// Are you sure? Not all party members have joined this quest! Quests start automatically when all players have joined or rejected the invitation.
    public static let confirmForceStart = L10n.tr("Mainstrings", "quests.confirm_force_start")
    /// Invitations
    public static let invitationsHeader = L10n.tr("Mainstrings", "quests.invitations_header")
    /// Participants
    public static let participantsHeader = L10n.tr("Mainstrings", "quests.participants_header")
    /// Pending
    public static let pending = L10n.tr("Mainstrings", "quests.pending")
    /// Rage attack: %@
    public static func rageAttack(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "quests.rage_attack", p1)
    }
    /// Rejected
    public static let rejected = L10n.tr("Mainstrings", "quests.rejected")
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
    public static let api = L10n.tr("Mainstrings", "settings.api")
    /// Copy these for use in third party applications. However, think of your API Token like a password, and do not share it publicly. You may occasionally be asked for your User ID, but never post your API Token where others can see it, including on Github.
    public static let apiDisclaimer = L10n.tr("Mainstrings", "settings.api_disclaimer")
    /// App Icon
    public static let appIcon = L10n.tr("Mainstrings", "settings.app_icon")
    /// Are you sure?
    public static let areYouSure = L10n.tr("Mainstrings", "settings.are_you_sure")
    /// Authentication
    public static let authentication = L10n.tr("Mainstrings", "settings.authentication")
    /// Change About Message
    public static let changeAboutMessage = L10n.tr("Mainstrings", "settings.change_about_message")
    /// Change Class
    public static let changeClass = L10n.tr("Mainstrings", "settings.change_class")
    /// This will reset your character's class and allocated points (you'll get them all back to re-allocate), and costs 3 gems.
    public static let changeClassDisclaimer = L10n.tr("Mainstrings", "settings.change_class_disclaimer")
    /// Change Display Name
    public static let changeDisplayName = L10n.tr("Mainstrings", "settings.change_display_name")
    /// Change Email
    public static let changeEmail = L10n.tr("Mainstrings", "settings.change_email")
    /// Change Password
    public static let changePassword = L10n.tr("Mainstrings", "settings.change_password")
    /// Change Photo URL
    public static let changePhotoUrl = L10n.tr("Mainstrings", "settings.change_photo_url")
    /// Change Username
    public static let changeUsername = L10n.tr("Mainstrings", "settings.change_username")
    /// Clear Cache
    public static let clearCache = L10n.tr("Mainstrings", "settings.clear_cache")
    /// Confirm new Password
    public static let confirmNewPassword = L10n.tr("Mainstrings", "settings.confirm_new_password")
    /// Confirming your username will make it public for invitations, @mentions and messaging. You can change your username from settings at any time.
    public static let confirmUsernameDescription = L10n.tr("Mainstrings", "settings.confirm_username_description")
    /// Are you sure you want to confirm your current username?
    public static let confirmUsernamePrompt = L10n.tr("Mainstrings", "settings.confirm_username_prompt")
    /// Custom Day Start
    public static let customDayStart = L10n.tr("Mainstrings", "settings.custom_day_start")
    /// Daily Reminder
    public static let dailyReminder = L10n.tr("Mainstrings", "settings.daily_reminder")
    /// Danger Zone
    public static let dangerZone = L10n.tr("Mainstrings", "settings.danger_zone")
    /// Day Start
    public static let dayStart = L10n.tr("Mainstrings", "settings.day_start")
    /// Delete Account
    public static let deleteAccount = L10n.tr("Mainstrings", "settings.delete_account")
    /// Are you sure? This will delete your account forever, and it can never be restored! You will need to register a new account to use Habitica again. Banked or spent Gems will not be refunded. If you're absolutely certain, type your password into the text box below.
    public static let deleteAccountDescription = L10n.tr("Mainstrings", "settings.delete_account_description")
    /// Disable all Push Notifications
    public static let disableAllNotifications = L10n.tr("Mainstrings", "settings.disable_all_notifications")
    /// Disable Private Messages
    public static let disablePm = L10n.tr("Mainstrings", "settings.disable_pm")
    /// Your display name has to be between 1 and 30 characters.
    public static let displayNameLengthError = L10n.tr("Mainstrings", "settings.display_name_length_error")
    /// Display Notification Badge
    public static let displayNotificationBadge = L10n.tr("Mainstrings", "settings.display_notification_badge")
    /// Enable Class System
    public static let enableClassSystem = L10n.tr("Mainstrings", "settings.enable_class_system")
    /// Every day at
    public static let everyDay = L10n.tr("Mainstrings", "settings.every_day")
    /// Fix Character Values
    public static let fixCharacterValues = L10n.tr("Mainstrings", "settings.fix_characterValues")
    /// If you’ve encountered a bug or made a mistake that unfairly changed your character, you can manually correct those values here.
    public static let fixValuesDescription = L10n.tr("Mainstrings", "settings.fix_values_description")
    /// Local
    public static let local = L10n.tr("Mainstrings", "settings.local")
    /// Log Out
    public static let logOut = L10n.tr("Mainstrings", "settings.log_out")
    /// Login Methods
    public static let loginMethods = L10n.tr("Mainstrings", "settings.login_methods")
    /// Maintenance
    public static let maintenance = L10n.tr("Mainstrings", "settings.maintenance")
    /// New Email
    public static let newEmail = L10n.tr("Mainstrings", "settings.new_email")
    /// New Password
    public static let newPassword = L10n.tr("Mainstrings", "settings.new_password")
    /// New Username
    public static let newUsername = L10n.tr("Mainstrings", "settings.new_username")
    /// Notification Badge
    public static let notificationBadge = L10n.tr("Mainstrings", "settings.notification_badge")
    /// Old Password
    public static let oldPassword = L10n.tr("Mainstrings", "settings.old_password")
    /// Preferences
    public static let preferences = L10n.tr("Mainstrings", "settings.preferences")
    /// Profile
    public static let profile = L10n.tr("Mainstrings", "settings.profile")
    /// Push Notifications
    public static let pushNotifications = L10n.tr("Mainstrings", "settings.push_notifications")
    /// Reload Content
    public static let reloadContent = L10n.tr("Mainstrings", "settings.reload_content")
    /// Reminder
    public static let reminder = L10n.tr("Mainstrings", "settings.reminder")
    /// Reset Account
    public static let resetAccount = L10n.tr("Mainstrings", "settings.reset_account")
    /// WARNING! This resets many parts of your account. This is highly discouraged, but some people find it useful in the beginning after playing with the site for a short time.\n\nYou will lose all your levels, gold, and experience points. All your tasks (except those from challenges) will be deleted permanently and you will lose all of their historical data. You will lose all your equipment but you will be able to buy it all back, including all limited edition equipment or subscriber Mystery items that you already own (you will need to be in the correct class to re-buy class-specific gear). You will keep your current class and your pets and mounts. You might prefer to use an Orb of Rebirth instead, which is a much safer option and which will preserve your tasks and equipment.
    public static let resetAccountDescription = L10n.tr("Mainstrings", "settings.reset_account_description")
    /// Select Class
    public static let selectClass = L10n.tr("Mainstrings", "settings.select_class")
    /// Server
    public static let server = L10n.tr("Mainstrings", "settings.server")
    /// Social
    public static let social = L10n.tr("Mainstrings", "settings.social")
    /// Sound Theme
    public static let soundTheme = L10n.tr("Mainstrings", "settings.sound_theme")
    /// Theme Color
    public static let themeColor = L10n.tr("Mainstrings", "settings.theme_color")
    /// User
    public static let user = L10n.tr("Mainstrings", "settings.user")
    /// Username not confirmed
    public static let usernameNotConfirmed = L10n.tr("Mainstrings", "settings.username_not_confirmed")
    /// Incorrect Password
    public static let wrongPassword = L10n.tr("Mainstrings", "settings.wrong_password")
  }

  public enum Shops {
    /// You can only purchase gear for your current class
    public static let otherClassDisclaimer = L10n.tr("Mainstrings", "shops.other_class_disclaimer")
    /// You already have all your class equipment! More will be released during the Grand Galas, near the solstices and equinoxes.
    public static let purchasedAllGear = L10n.tr("Mainstrings", "shops.purchased_all_gear")
  }

  public enum Skills {
    /// Can't cast a spell on a challenge task
    public static let cantCastOnChallengeTasks = L10n.tr("Mainstrings", "skills.cant_cast_on_challenge_tasks")
    /// Transformation Items
    public static let transformationItems = L10n.tr("Mainstrings", "skills.transformation_items")
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
    public static let feed = L10n.tr("Mainstrings", "stable.feed")
    /// Magic Potion
    public static let premium = L10n.tr("Mainstrings", "stable.premium")
    /// Quest Mounts
    public static let questMounts = L10n.tr("Mainstrings", "stable.quest_mounts")
    /// Quest Pets
    public static let questPets = L10n.tr("Mainstrings", "stable.quest_pets")
    /// Special Mounts
    public static let specialMounts = L10n.tr("Mainstrings", "stable.special_mounts")
    /// Special Pets
    public static let specialPets = L10n.tr("Mainstrings", "stable.special_pets")
    /// Standard
    public static let standard = L10n.tr("Mainstrings", "stable.standard")
    /// Standard Mounts
    public static let standardMounts = L10n.tr("Mainstrings", "stable.standard_mounts")
    /// Standard Pets
    public static let standardPets = L10n.tr("Mainstrings", "stable.standard_pets")
  }

  public enum Stats {
    /// Allocated
    public static let allocated = L10n.tr("Mainstrings", "stats.allocated")
    /// Auto Allocate Points
    public static let autoAllocatePoints = L10n.tr("Mainstrings", "stats.auto_allocate_points")
    /// Battle Gear
    public static let battleGear = L10n.tr("Mainstrings", "stats.battle_gear")
    /// Buffs
    public static let buffs = L10n.tr("Mainstrings", "stats.buffs")
    /// Each level earns you one point to assign to an attribute of your choice. You can do so manually, or let the game decide for you using one of the Automatic Allocation options.
    public static let characterBuildText = L10n.tr("Mainstrings", "stats.character_build_text")
    /// Character Build
    public static let characterBuildTitle = L10n.tr("Mainstrings", "stats.character_build_title")
    /// Class-Bonus
    public static let classBonus = L10n.tr("Mainstrings", "stats.class_bonus")
    /// Decreases the amount of damage taken from your tasks. Does not decrease the damage received from bosses.
    public static let constitutionText = L10n.tr("Mainstrings", "stats.constitution_text")
    /// Constitution
    public static let constitutionTitle = L10n.tr("Mainstrings", "stats.constitution_title")
    /// Distribute based on class
    public static let distributeClass = L10n.tr("Mainstrings", "stats.distribute_class")
    /// Assigns more points to the attributes important to your Class.
    public static let distributeClassHelp = L10n.tr("Mainstrings", "stats.distribute_class_help")
    /// Distribute evenly
    public static let distributeEvenly = L10n.tr("Mainstrings", "stats.distribute_evenly")
    /// Assigns the same number of points to each attribute.
    public static let distributeEvenlyHelp = L10n.tr("Mainstrings", "stats.distribute_evenly_help")
    /// Distribute based on task activity
    public static let distributeTasks = L10n.tr("Mainstrings", "stats.distribute_tasks")
    /// Assigns points based on the Strength, Intelligence, Constitution, and Perception categories associated with the tasks you complete.
    public static let distributeTasksHelp = L10n.tr("Mainstrings", "stats.distribute_tasks_help")
    /// Increases EXP earned from completing tasks. Also increases your mana cap and how fast mana regenerates over time.
    public static let intelligenceText = L10n.tr("Mainstrings", "stats.intelligence_text")
    /// Intelligence
    public static let intelligenceTitle = L10n.tr("Mainstrings", "stats.intelligence_title")
    /// Level
    public static let level = L10n.tr("Mainstrings", "stats.level")
    /// 0 Points to Allocate
    public static let noPointsToAllocate = L10n.tr("Mainstrings", "stats.no_points_to_allocate")
    /// 1 Point to Allocate
    public static let onePointToAllocate = L10n.tr("Mainstrings", "stats.one_point_to_allocate")
    /// Increases the likelihood of finding drops when completing Tasks, the daily drop-cap, Streak Bonuses, and the amount of gold awarded for Tasks.
    public static let perceptionText = L10n.tr("Mainstrings", "stats.perception_text")
    /// Perception
    public static let perceptionTitle = L10n.tr("Mainstrings", "stats.perception_title")
    /// %d Point to Allocate
    public static func pointsToAllocate(_ p1: Int) -> String {
      return L10n.tr("Mainstrings", "stats.points_to_allocate", p1)
    }
    /// Stat guide
    public static let statGuide = L10n.tr("Mainstrings", "stats.stat_guide")
    /// Increases the bonus of critical hits and makes them more likely when scoring a task. Also increases damage dealt to bosses. 
    public static let strengthText = L10n.tr("Mainstrings", "stats.strength_text")
    /// Strength
    public static let strengthTitle = L10n.tr("Mainstrings", "stats.strength_title")
    /// Total
    public static let total = L10n.tr("Mainstrings", "stats.total")
  }

  public enum Tasks {
    /// Add %@
    public static func addX(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "tasks.add_x", p1)
    }
    /// Chores
    public static let chores = L10n.tr("Mainstrings", "tasks.chores")
    /// Creativity
    public static let creativity = L10n.tr("Mainstrings", "tasks.creativity")
    /// Dailies
    public static let dailies = L10n.tr("Mainstrings", "tasks.dailies")
    /// Daily
    public static let daily = L10n.tr("Mainstrings", "tasks.daily")
    /// Due in %d days
    public static func dueInXDays(_ p1: Int) -> String {
      return L10n.tr("Mainstrings", "tasks.due_in_x_days", p1)
    }
    /// Due today
    public static let dueToday = L10n.tr("Mainstrings", "tasks.due_today")
    /// Due tomorrow
    public static let dueTomorrow = L10n.tr("Mainstrings", "tasks.due_tomorrow")
    /// Due %@
    public static func dueX(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "tasks.due_x", p1)
    }
    /// every %@
    public static func everyX(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "tasks.every_x", p1)
    }
    /// Exercise
    public static let exercise = L10n.tr("Mainstrings", "tasks.exercise")
    /// Habit
    public static let habit = L10n.tr("Mainstrings", "tasks.habit")
    /// Habits
    public static let habits = L10n.tr("Mainstrings", "tasks.habits")
    /// Health
    public static let health = L10n.tr("Mainstrings", "tasks.health")
    /// Reward
    public static let reward = L10n.tr("Mainstrings", "tasks.reward")
    /// Rewards
    public static let rewards = L10n.tr("Mainstrings", "tasks.rewards")
    /// School
    public static let school = L10n.tr("Mainstrings", "tasks.school")
    /// Team
    public static let team = L10n.tr("Mainstrings", "tasks.team")
    /// To-Do
    public static let todo = L10n.tr("Mainstrings", "tasks.todo")
    /// To-Dos
    public static let todos = L10n.tr("Mainstrings", "tasks.todos")
    /// Work
    public static let work = L10n.tr("Mainstrings", "tasks.work")

    public enum Examples {
      /// Tap to choose your schedule!
      public static let choresDailyNotes = L10n.tr("Mainstrings", "tasks.examples.chores_daily_notes")
      /// Wash dishes
      public static let choresDailyText = L10n.tr("Mainstrings", "tasks.examples.chores_daily_text")
      /// 10 minutes cleaning
      public static let choresHabit = L10n.tr("Mainstrings", "tasks.examples.chores_habit")
      /// Tap to specify the cluttered area!
      public static let choresTodoNotes = L10n.tr("Mainstrings", "tasks.examples.chores_todo_notes")
      /// Organize clutter
      public static let choresTodoText = L10n.tr("Mainstrings", "tasks.examples.chores_todo_text")
      /// Tap to specify the name of your current project + set the schedule!
      public static let creativityDailyNotes = L10n.tr("Mainstrings", "tasks.examples.creativity_daily_notes")
      /// Work on creative project
      public static let creativityDailyText = L10n.tr("Mainstrings", "tasks.examples.creativity_daily_text")
      /// Practiced a new creative technique
      public static let creativityHabit = L10n.tr("Mainstrings", "tasks.examples.creativity_habit")
      /// Tap to specify the name of your project
      public static let creativityTodoNotes = L10n.tr("Mainstrings", "tasks.examples.creativity_todo_notes")
      /// Finish creative project
      public static let creativityTodoText = L10n.tr("Mainstrings", "tasks.examples.creativity_todo_text")
      /// Tap to choose your schedule and specify exercises!
      public static let exerciseDailyNotes = L10n.tr("Mainstrings", "tasks.examples.exercise_daily_notes")
      /// Daily workout routine
      public static let exerciseDailyText = L10n.tr("Mainstrings", "tasks.examples.exercise_daily_text")
      /// 10 minutes cardio
      public static let exerciseHabit = L10n.tr("Mainstrings", "tasks.examples.exercise_habit")
      /// Tap to add a checklist!
      public static let exerciseTodoNotes = L10n.tr("Mainstrings", "tasks.examples.exercise_todo_notes")
      /// Set up workout schedule
      public static let exerciseTodoText = L10n.tr("Mainstrings", "tasks.examples.exercise_todo_text")
      /// Or delete it by swiping left
      public static let habitNotes = L10n.tr("Mainstrings", "tasks.examples.habit_notes")
      /// Tap here to edit this into a bad habit you'd like to quit
      public static let habitText = L10n.tr("Mainstrings", "tasks.examples.habit_text")
      /// Tap to make any changes!
      public static let healthDailyNotes = L10n.tr("Mainstrings", "tasks.examples.health_daily_notes")
      /// Floss
      public static let healthDailyText = L10n.tr("Mainstrings", "tasks.examples.health_daily_text")
      /// Eat health/junk food
      public static let healthHabit = L10n.tr("Mainstrings", "tasks.examples.health_habit")
      /// Tap to add checklists!
      public static let healthTodoNotes = L10n.tr("Mainstrings", "tasks.examples.health_todo_notes")
      /// Brainstorm a healthy change
      public static let healthTodoText = L10n.tr("Mainstrings", "tasks.examples.health_todo_text")
      /// Watch TV, play a game, eat a treat, it’s up to you!
      public static let rewardNotes = L10n.tr("Mainstrings", "tasks.examples.reward_notes")
      /// Reward yourself
      public static let rewardText = L10n.tr("Mainstrings", "tasks.examples.reward_text")
      /// Tap to specify your most important task
      public static let schoolDailyNotes = L10n.tr("Mainstrings", "tasks.examples.school_daily_notes")
      /// Do homework
      public static let schoolDailyText = L10n.tr("Mainstrings", "tasks.examples.school_daily_text")
      /// Study/Procrastinate
      public static let schoolHabit = L10n.tr("Mainstrings", "tasks.examples.school_habit")
      /// Tap to specify your most important task
      public static let schoolTodoNotes = L10n.tr("Mainstrings", "tasks.examples.school_todo_notes")
      /// Finish assignment for class
      public static let schoolTodoText = L10n.tr("Mainstrings", "tasks.examples.school_todo_text")
      /// Tap to specify your most important task
      public static let teamDailyNotes = L10n.tr("Mainstrings", "tasks.examples.team_daily_notes")
      /// Update team on status
      public static let teamDailyText = L10n.tr("Mainstrings", "tasks.examples.team_daily_text")
      /// Check in with team
      public static let teamHabit = L10n.tr("Mainstrings", "tasks.examples.team_habit")
      /// Tap to specify your most important task
      public static let teamTodoNotes = L10n.tr("Mainstrings", "tasks.examples.team_todo_notes")
      /// Complete team project
      public static let teamTodoText = L10n.tr("Mainstrings", "tasks.examples.team_todo_text")
      /// You can either complete this To-Do, edit it, or remove it.
      public static let todoNotes = L10n.tr("Mainstrings", "tasks.examples.todo_notes")
      /// Join Habitica (Check me off!)
      public static let todoText = L10n.tr("Mainstrings", "tasks.examples.todo_text")
      /// Tap to specify your most important task
      public static let workDailyNotes = L10n.tr("Mainstrings", "tasks.examples.work_daily_notes")
      /// Worked on today’s most important task
      public static let workDailyText = L10n.tr("Mainstrings", "tasks.examples.work_daily_text")
      /// Process email
      public static let workHabit = L10n.tr("Mainstrings", "tasks.examples.work_habit")
      /// Tap to specify the name of your current project + set a due date!
      public static let workTodoNotes = L10n.tr("Mainstrings", "tasks.examples.work_todo_notes")
      /// Complete work project
      public static let workTodoText = L10n.tr("Mainstrings", "tasks.examples.work_todo_text")
    }

    public enum Form {
      /// Checklist
      public static let checklist = L10n.tr("Mainstrings", "tasks.form.checklist")
      /// Clear
      public static let clear = L10n.tr("Mainstrings", "tasks.form.clear")
      /// Are you sure you want to delete this task?
      public static let confirmDelete = L10n.tr("Mainstrings", "tasks.form.confirm_delete")
      /// Controls
      public static let controls = L10n.tr("Mainstrings", "tasks.form.controls")
      /// Cost
      public static let cost = L10n.tr("Mainstrings", "tasks.form.cost")
      /// New %@
      public static func create(_ p1: String) -> String {
        return L10n.tr("Mainstrings", "tasks.form.create", p1)
      }
      /// What do you want to do regularly?
      public static let dailiesTitlePlaceholder = L10n.tr("Mainstrings", "tasks.form.dailies_title_placeholder")
      /// Day of the month
      public static let dayOfMonth = L10n.tr("Mainstrings", "tasks.form.day_of_month")
      /// Day of the week
      public static let dayOfWeek = L10n.tr("Mainstrings", "tasks.form.day_of_week")
      /// Difficulty
      public static let difficulty = L10n.tr("Mainstrings", "tasks.form.difficulty")
      /// Due date
      public static let dueDate = L10n.tr("Mainstrings", "tasks.form.due_date")
      /// Easy
      public static let easy = L10n.tr("Mainstrings", "tasks.form.easy")
      /// Edit %@
      public static func edit(_ p1: String) -> String {
        return L10n.tr("Mainstrings", "tasks.form.edit", p1)
      }
      /// Every
      public static let every = L10n.tr("Mainstrings", "tasks.form.every")
      /// What habits do you want to foster or break?
      public static let habitTitlePlaceholder = L10n.tr("Mainstrings", "tasks.form.habit_title_placeholder")
      /// Hard
      public static let hard = L10n.tr("Mainstrings", "tasks.form.hard")
      /// Medium
      public static let medium = L10n.tr("Mainstrings", "tasks.form.medium")
      /// New checklist item
      public static let newChecklistItem = L10n.tr("Mainstrings", "tasks.form.new_checklist_item")
      /// New reminder
      public static let newReminder = L10n.tr("Mainstrings", "tasks.form.new_reminder")
      /// Include any notes to help you out
      public static let notesPlaceholder = L10n.tr("Mainstrings", "tasks.form.notes_placeholder")
      /// Remind me
      public static let remindMe = L10n.tr("Mainstrings", "tasks.form.remind_me")
      /// Reminders
      public static let reminders = L10n.tr("Mainstrings", "tasks.form.reminders")
      /// Repeats
      public static let repeats = L10n.tr("Mainstrings", "tasks.form.repeats")
      /// Reset Streak
      public static let resetStreak = L10n.tr("Mainstrings", "tasks.form.reset_streak")
      /// How do you want to reward yourself?
      public static let rewardsTitlePlaceholder = L10n.tr("Mainstrings", "tasks.form.rewards_title_placeholder")
      /// Scheduling
      public static let scheduling = L10n.tr("Mainstrings", "tasks.form.scheduling")
      /// Start date
      public static let startDate = L10n.tr("Mainstrings", "tasks.form.start_date")
      /// Tags
      public static let tags = L10n.tr("Mainstrings", "tasks.form.tags")
      /// What do you want to complete once?
      public static let todosTitlePlaceholder = L10n.tr("Mainstrings", "tasks.form.todos_title_placeholder")
      /// Trivial
      public static let trivial = L10n.tr("Mainstrings", "tasks.form.trivial")

      public enum Accessibility {
        /// Disable %@
        public static func disable(_ p1: String) -> String {
          return L10n.tr("Mainstrings", "tasks.form.accessibility.disable", p1)
        }
        /// Disable negative action.
        public static let disableNegative = L10n.tr("Mainstrings", "tasks.form.accessibility.disable_negative")
        /// Disable positive action.
        public static let disablePositive = L10n.tr("Mainstrings", "tasks.form.accessibility.disable_positive")
        /// Enable %@
        public static func enable(_ p1: String) -> String {
          return L10n.tr("Mainstrings", "tasks.form.accessibility.enable", p1)
        }
        /// Enable negative action.
        public static let enableNegative = L10n.tr("Mainstrings", "tasks.form.accessibility.enable_negative")
        /// Enable positive action.
        public static let enablePositive = L10n.tr("Mainstrings", "tasks.form.accessibility.enable_positive")
        /// Negative habit action enabled.
        public static let negativeEnabled = L10n.tr("Mainstrings", "tasks.form.accessibility.negative_enabled")
        /// Positive and negative habit actions enabled.
        public static let positiveAndNegativeEnabled = L10n.tr("Mainstrings", "tasks.form.accessibility.positive_and_negative_enabled")
        /// Positive habit action enabled.
        public static let positiveEnabled = L10n.tr("Mainstrings", "tasks.form.accessibility.positive_enabled")
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
      public static let bad = L10n.tr("Mainstrings", "tasks.quality.bad")
      /// Best
      public static let best = L10n.tr("Mainstrings", "tasks.quality.best")
      /// Better
      public static let better = L10n.tr("Mainstrings", "tasks.quality.better")
      /// Good
      public static let good = L10n.tr("Mainstrings", "tasks.quality.good")
      /// Neutral
      public static let neutral = L10n.tr("Mainstrings", "tasks.quality.neutral")
      /// Worse
      public static let worse = L10n.tr("Mainstrings", "tasks.quality.worse")
      /// Worst
      public static let worst = L10n.tr("Mainstrings", "tasks.quality.worst")
    }

    public enum Repeats {
      /// daily
      public static let daily = L10n.tr("Mainstrings", "tasks.repeats.daily")
      /// every day
      public static let everyDay = L10n.tr("Mainstrings", "tasks.repeats.every_day")
      /// monthly
      public static let monthly = L10n.tr("Mainstrings", "tasks.repeats.monthly")
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
      public static let weekdays = L10n.tr("Mainstrings", "tasks.repeats.weekdays")
      /// weekends
      public static let weekends = L10n.tr("Mainstrings", "tasks.repeats.weekends")
      /// weekly
      public static let weekly = L10n.tr("Mainstrings", "tasks.repeats.weekly")
      /// yearly
      public static let yearly = L10n.tr("Mainstrings", "tasks.repeats.yearly")
    }
  }

  public enum Theme {
    /// Blue
    public static let blue = L10n.tr("Mainstrings", "theme.blue")
    /// Default
    public static let defaultTheme = L10n.tr("Mainstrings", "theme.default_theme")
    /// Green
    public static let green = L10n.tr("Mainstrings", "theme.green")
    /// Maroon
    public static let maroon = L10n.tr("Mainstrings", "theme.maroon")
    /// Orange
    public static let orange = L10n.tr("Mainstrings", "theme.orange")
    /// Red
    public static let red = L10n.tr("Mainstrings", "theme.red")
    /// Teal
    public static let teal = L10n.tr("Mainstrings", "theme.teal")
    /// Yellow
    public static let yellow = L10n.tr("Mainstrings", "theme.yellow")
  }

  public enum Titles {
    /// About
    public static let about = L10n.tr("Mainstrings", "titles.about")
    /// API
    public static let api = L10n.tr("Mainstrings", "titles.api")
    /// Authentication
    public static let authentication = L10n.tr("Mainstrings", "titles.authentication")
    /// Avatar
    public static let avatar = L10n.tr("Mainstrings", "titles.avatar")
    /// Challenges
    public static let challenges = L10n.tr("Mainstrings", "titles.challenges")
    /// Choose Recipient
    public static let chooseRecipient = L10n.tr("Mainstrings", "titles.choose_recipient")
    /// Choose User
    public static let chooseUser = L10n.tr("Mainstrings", "titles.choose_user")
    /// Equipment
    public static let equipment = L10n.tr("Mainstrings", "titles.equipment")
    /// FAQ
    public static let faq = L10n.tr("Mainstrings", "titles.faq")
    /// Feed Pet
    public static let feedPet = L10n.tr("Mainstrings", "titles.feed_pet")
    /// Fix Values
    public static let fixValues = L10n.tr("Mainstrings", "titles.fix_values")
    /// Gift Subscription
    public static let giftSubscription = L10n.tr("Mainstrings", "titles.gift_subscription")
    /// Guidelines
    public static let guidelines = L10n.tr("Mainstrings", "titles.guidelines")
    /// Guild
    public static let guild = L10n.tr("Mainstrings", "titles.guild")
    /// Guilds
    public static let guilds = L10n.tr("Mainstrings", "titles.guilds")
    /// Invite Members
    public static let inviteMembers = L10n.tr("Mainstrings", "titles.invite_members")
    /// Items
    public static let items = L10n.tr("Mainstrings", "titles.items")
    /// Mounts
    public static let mounts = L10n.tr("Mainstrings", "titles.mounts")
    /// News
    public static let news = L10n.tr("Mainstrings", "titles.news")
    /// Party
    public static let party = L10n.tr("Mainstrings", "titles.party")
    /// Pets
    public static let pets = L10n.tr("Mainstrings", "titles.pets")
    /// Profile
    public static let profile = L10n.tr("Mainstrings", "titles.profile")
    /// Select Class
    public static let selectClass = L10n.tr("Mainstrings", "titles.select_class")
    /// Settings
    public static let settings = L10n.tr("Mainstrings", "titles.settings")
    /// Shops
    public static let shops = L10n.tr("Mainstrings", "titles.shops")
    /// Skills
    public static let skills = L10n.tr("Mainstrings", "titles.skills")
    /// Spells
    public static let spells = L10n.tr("Mainstrings", "titles.spells")
    /// Stable
    public static let stable = L10n.tr("Mainstrings", "titles.stable")
    /// Stats
    public static let stats = L10n.tr("Mainstrings", "titles.stats")
    /// Tavern
    public static let tavern = L10n.tr("Mainstrings", "titles.tavern")
  }

  public enum Tutorials {
    /// Tap to add a new task.
    public static let addTask = L10n.tr("Mainstrings", "tutorials.add_task")
    /// Make Dailies for time-sensitive tasks that need to be done on a regular schedule.
    public static let dailies1 = L10n.tr("Mainstrings", "tutorials.dailies_1")
    /// Be careful — if you miss one, your avatar will take damage overnight. Checking them off consistently brings great rewards!
    public static let dailies2 = L10n.tr("Mainstrings", "tutorials.dailies_2")
    /// Tap a task to edit it and add reminders. Swipe left to delete it.
    public static let editTask = L10n.tr("Mainstrings", "tutorials.edit_task")
    /// Tap to filter tasks.
    public static let filterTask = L10n.tr("Mainstrings", "tutorials.filter_task")
    /// First up is Habits. They can be positive Habits you want to improve or negative Habits you want to quit.
    public static let habits1 = L10n.tr("Mainstrings", "tutorials.habits_1")
    /// Every time you do a positive Habit, tap the + to get experience and gold!
    public static let habits2 = L10n.tr("Mainstrings", "tutorials.habits_2")
    /// If you slip up and do a negative Habit, tapping the - will reduce your avatar’s health to help you stay accountable.
    public static let habits3 = L10n.tr("Mainstrings", "tutorials.habits_3")
    /// Give it a shot! You can explore the other task types through the bottom navigation.
    public static let habits4 = L10n.tr("Mainstrings", "tutorials.habits_4")
    /// This is where you can read and reply to private messages! You can also message people from their profiles.
    public static let inbox = L10n.tr("Mainstrings", "tutorials.inbox")
    /// Hold down on a task to drag it around.
    public static let reorderTask = L10n.tr("Mainstrings", "tutorials.reorder_task")
    /// Buy gear for your avatar with the gold you earn!
    public static let rewards1 = L10n.tr("Mainstrings", "tutorials.rewards_1")
    /// You can also make real-world Custom Rewards based on what motivates you.
    public static let rewards2 = L10n.tr("Mainstrings", "tutorials.rewards_2")
    /// Skills are special abilities that have powerful effects! Tap on a skill to use it. It will cost Mana (the blue bar), which you earn by checking in every day and by completing your real-life tasks. Check out the FAQ in the menu for more info!
    public static let spells = L10n.tr("Mainstrings", "tutorials.spells")
    /// Tap the gray button to allocate lots of your stats at once, or tap the arrows to add them one point at a time.
    public static let stats = L10n.tr("Mainstrings", "tutorials.stats")
    /// Use To-Dos to keep track of tasks you need to do just once.
    public static let todos1 = L10n.tr("Mainstrings", "tutorials.todos_1")
    /// If your To-Do has to be done by a certain time, set a due date. Looks like you can check one off — go ahead!
    public static let todos2 = L10n.tr("Mainstrings", "tutorials.todos_2")
  }

  public enum WorldBoss {
    /// Defeat the Boss to earn special rewards and save Habitica from %@'s Terror!
    public static func actionPrompt(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "world_boss.action_prompt", p1)
    }
    /// A World Boss is a special event where the whole community works together to take down a powerful monster with their tasks!
    public static let description = L10n.tr("Mainstrings", "world_boss.description")
    /// Complete tasks to damage the Boss
    public static let firstBullet = L10n.tr("Mainstrings", "world_boss.first_bullet")
    /// Check the Tavern to see Boss progress and Rage attacks
    public static let fourthBullet = L10n.tr("Mainstrings", "world_boss.fourth_bullet")
    /// Pending Strike
    public static let pendingStrike = L10n.tr("Mainstrings", "world_boss.pending_strike")
    /// %@ is Heartbroken!\nOur beloved %@ was devastated when %@ shattered the %@. Quickly, tackle your tasks to defeat the monster and help rebuild!
    public static func rageStrikeDamaged(_ p1: String, _ p2: String, _ p3: String, _ p4: String) -> String {
      return L10n.tr("Mainstrings", "world_boss.rage_strike_damaged", p1, p2, p3, p4)
    }
    /// There are 3 potential Rage Strikes\nThis gauge fills when Habiticans miss their Dailies. If it fills up, the DysHeartener will unleash its Shattering Heartbreak attack on one of Habitica's shopkeepers, so be sure to do your tasks!
    public static let rageStrikeExplanation = L10n.tr("Mainstrings", "world_boss.rage_strike_explanation")
    /// What's a Rage Strike?
    public static let rageStrikeExplanationButton = L10n.tr("Mainstrings", "world_boss.rage_strike_explanation_button")
    /// The %@ was Attacked!
    public static func rageStrikeTitle(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "world_boss.rage_strike_title", p1)
    }
    /// Be careful...\nThe World Boss will lash out and attack one of our friendly shopkeepers once its rage bar fills. Keep up with your Dailies to try and prevent it from happening!
    public static let rageStrikeWarning = L10n.tr("Mainstrings", "world_boss.rage_strike_warning")
    /// The Boss won’t damage you for missed tasks, but its Rage meter will go up. If the bar fills up, the Boss will attack one of the shopkeepers!
    public static let secondBullet = L10n.tr("Mainstrings", "world_boss.second_bullet")
    /// You can continue with normal Quest Bosses, damage will apply to both
    public static let thirdBullet = L10n.tr("Mainstrings", "world_boss.third_bullet")
    /// The %@ attacks!
    public static func title(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "world_boss.title", p1)
    }
    /// World Boss
    public static let worldBoss = L10n.tr("Mainstrings", "world_boss.world_boss")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    var format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
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
