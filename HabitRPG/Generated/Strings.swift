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
  /// Add
  public static var add: String { return L10n.tr("Mainstrings", "add") }
  /// Complete these onboarding tasks and you’ll earn 5 Achievements and 100 Gold once you’re done!
  public static var adventureGuideDescription: String { return L10n.tr("Mainstrings", "adventure_guide_description") }
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
  /// Backer Tier: %d
  public static func backerTier(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "backer_tier", p1)
  }
  /// Bangs
  public static var bangs: String { return L10n.tr("Mainstrings", "bangs") }
  /// You have earned the “Beast Master” Achievement for collecting all the pets!
  public static var beastMasterDescription: String { return L10n.tr("Mainstrings", "beastMasterDescription") }
  /// Beast Master
  public static var beastMasterTitle: String { return L10n.tr("Mainstrings", "beastMasterTitle") }
  /// Block
  public static var block: String { return L10n.tr("Mainstrings", "block") }
  /// A blocked user cannot send you Private Messages but you will still see their posts in Tavern or Guilds. This will have no effect if the person is a moderator now or in the future.
  public static var blockDescription: String { return L10n.tr("Mainstrings", "block_description") }
  /// Block
  public static var blockUser: String { return L10n.tr("Mainstrings", "block_user") }
  /// Block %@?
  public static func blockUsername(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "block_username", p1)
  }
  /// Body Size
  public static var bodySize: String { return L10n.tr("Mainstrings", "body_size") }
  /// Broad
  public static var broad: String { return L10n.tr("Mainstrings", "broad") }
  /// Broken Challenge
  public static var brokenChallenge: String { return L10n.tr("Mainstrings", "broken_challenge") }
  /// This is one of %d tasks that are part of a Challenge that no longer exists. What would you like to do with these left over tasks?
  public static func brokenChallengeDescription(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "broken_challenge_description", p1)
  }
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
  /// You bought '%@' for %@ gold
  public static func buyReward(_ p1: String, _ p2: String) -> String {
    return L10n.tr("Mainstrings", "buy_reward", p1, p2)
  }
  /// Combine your %@ Egg and %@ Potion to hatch this pet!
  public static func canHatchPet(_ p1: String, _ p2: String) -> String {
    return L10n.tr("Mainstrings", "can_hatch_pet", p1, p2)
  }
  /// Cancel
  public static var cancel: String { return L10n.tr("Mainstrings", "cancel") }
  /// Cancel Subscription
  public static var cancelSubscription: String { return L10n.tr("Mainstrings", "cancel_subscription") }
  /// You have a free subscription because you are a member a Party or Guild that has a Group Plan. This will end if you leave or the Group Plan is cancelled by the owner. Any months of extra subscription credit you have will be applied at the end of the Group Plan.
  public static var cancelSubscriptionGroupPlan: String { return L10n.tr("Mainstrings", "cancel_subscription_group_plan") }
  /// Cancelled
  public static var cancelled: String { return L10n.tr("Mainstrings", "cancelled") }
  /// You put themselves to the test by joining a Challenge!
  public static var challengeJoinedDescription: String { return L10n.tr("Mainstrings", "challengeJoinedDescription") }
  /// Joined a Challenge
  public static var challengeJoinedTitle: String { return L10n.tr("Mainstrings", "challengeJoinedTitle") }
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
  /// Class System disabled.
  public static var classSystemDisabled: String { return L10n.tr("Mainstrings", "class_system_disabled") }
  /// You can enable the class system from the apps settings.
  public static var classSystemEnableInstructions: String { return L10n.tr("Mainstrings", "class_system_enable_instructions") }
  /// Clear
  public static var clear: String { return L10n.tr("Mainstrings", "clear") }
  /// To do this, open Menu > Settings then scroll to the bottom to find the buttons
  public static var clearCacheDescription: String { return L10n.tr("Mainstrings", "clear_cache_description") }
  /// Clear Cache & Reload Content
  public static var clearCacheTitle: String { return L10n.tr("Mainstrings", "clear_cache_title") }
  /// Close
  public static var close: String { return L10n.tr("Mainstrings", "close") }
  /// Collect
  public static var collect: String { return L10n.tr("Mainstrings", "collect") }
  /// Color
  public static var color: String { return L10n.tr("Mainstrings", "color") }
  /// Common Fixes
  public static var commonFixes: String { return L10n.tr("Mainstrings", "common_fixes") }
  /// Common Questions
  public static var commonQuestions: String { return L10n.tr("Mainstrings", "common_questions") }
  /// Complete
  public static var complete: String { return L10n.tr("Mainstrings", "complete") }
  /// You need to complete more tasks before you can afford this item!
  public static var completeMoreTasks: String { return L10n.tr("Mainstrings", "complete_more_tasks") }
  /// Check off any of your tasks to earn rewards
  public static var completeTaskDescription: String { return L10n.tr("Mainstrings", "complete_task_description") }
  /// Complete a Task
  public static var completeTaskTitle: String { return L10n.tr("Mainstrings", "complete_task_title") }
  /// Complete to earn 100 Gold!
  public static var completeToEarnGold: String { return L10n.tr("Mainstrings", "complete_to_earn_gold") }
  /// A task can be a Habit, Daily, or To Do. Continue completing them to receive all sorts of rewards!
  public static var completedTaskDescription: String { return L10n.tr("Mainstrings", "completedTaskDescription") }
  /// Completed a task
  public static var completedTaskTitle: String { return L10n.tr("Mainstrings", "completedTaskTitle") }
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
  /// Copied %@ to Clipboard
  public static func copiedXToClipboard(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "copied_x_to_clipboard", p1)
  }
  /// Could not gift gems. Please try again later.
  public static var couldNotGiftGems: String { return L10n.tr("Mainstrings", "could_not_gift_gems") }
  /// Create
  public static var create: String { return L10n.tr("Mainstrings", "create") }
  /// Create Guild
  public static var createGuild: String { return L10n.tr("Mainstrings", "create_guild") }
  /// To create a Guild, log in to the Habitica website then tap the “Create” button on the “My Guilds” screen.
  public static var createGuildDescription: String { return L10n.tr("Mainstrings", "create_guild_description") }
  /// Create Tag
  public static var createTag: String { return L10n.tr("Mainstrings", "create_tag") }
  /// Add a task for something you would like to accomplish this week
  public static var createTaskDescription: String { return L10n.tr("Mainstrings", "create_task_description") }
  /// Create a Task
  public static var createTaskTitle: String { return L10n.tr("Mainstrings", "create_task_title") }
  /// Keep it up! If you need help planning tasks, try thinking about what you’d like to do during a specific time of day
  public static var createdTaskDescription: String { return L10n.tr("Mainstrings", "createdTaskDescription") }
  /// Created your first task
  public static var createdTaskTitle: String { return L10n.tr("Mainstrings", "createdTaskTitle") }
  /// Currency
  public static var currency: String { return L10n.tr("Mainstrings", "currency") }
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
  /// Decline
  public static var decline: String { return L10n.tr("Mainstrings", "decline") }
  /// Defeat
  public static var defeat: String { return L10n.tr("Mainstrings", "defeat") }
  /// Delete
  public static var delete: String { return L10n.tr("Mainstrings", "delete") }
  /// Delete Challenge Task?
  public static var deleteChallengeTask: String { return L10n.tr("Mainstrings", "delete_challenge_task") }
  /// This is one of %d tasks that are part of the “%s” Challenge. You must leave the Challenge to delete this task.
  public static func deleteChallengeTaskDescription(_ p1: Int, _ p2: UnsafePointer<CChar>) -> String {
    return L10n.tr("Mainstrings", "delete_challenge_task_description", p1, p2)
  }
  /// Delete Tasks
  public static var deleteTasks: String { return L10n.tr("Mainstrings", "delete_tasks") }
  /// Delete %d Tasks
  public static func deleteXTasks(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "delete_x_tasks", p1)
  }
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
  /// 12 months
  public static var duration12month: String { return L10n.tr("Mainstrings", "duration_12month") }
  /// 3 months
  public static var duration3month: String { return L10n.tr("Mainstrings", "duration_3month") }
  /// 6 months
  public static var duration6month: String { return L10n.tr("Mainstrings", "duration_6month") }
  /// month
  public static var durationMonth: String { return L10n.tr("Mainstrings", "duration_month") }
  /// I earned a new achievement in Habitica!
  public static var earnedAchievementShare: String { return L10n.tr("Mainstrings", "earned_achievement_share") }
  /// Edit
  public static var edit: String { return L10n.tr("Mainstrings", "edit") }
  /// Challenge tasks only offer limited editing.
  public static var editChallengeTasks: String { return L10n.tr("Mainstrings", "edit_challenge_tasks") }
  /// Edit Tag
  public static var editTag: String { return L10n.tr("Mainstrings", "edit_tag") }
  /// Egg
  public static var egg: String { return L10n.tr("Mainstrings", "egg") }
  /// Eggs
  public static var eggs: String { return L10n.tr("Mainstrings", "eggs") }
  /// Email
  public static var email: String { return L10n.tr("Mainstrings", "email") }
  /// End Challenge
  public static var endChallenge: String { return L10n.tr("Mainstrings", "end_challenge") }
  /// To end a Challenge, log in to the Habitica website then tap the “End Challenge” button on the right of the Challenge screen.
  public static var endChallengeDescription: String { return L10n.tr("Mainstrings", "end_challenge_description") }
  /// Ending on %@
  public static func endingOn(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "ending_on", p1)
  }
  /// Equip
  public static var equip: String { return L10n.tr("Mainstrings", "equip") }
  /// Excess Items
  public static var excessItems: String { return L10n.tr("Mainstrings", "excess_items") }
  /// You already have everything you need for all %@ pets. Are you sure you want to purchase %d %@s?
  public static func excessNoItemsLeft(_ p1: String, _ p2: Int, _ p3: String) -> String {
    return L10n.tr("Mainstrings", "excess_no_items_left", p1, p2, p3)
  }
  /// You only need %d %@s to hatch all possible pets. Are you sure you want to purchase %d?
  public static func excessXItemsLeft(_ p1: Int, _ p2: String, _ p3: Int) -> String {
    return L10n.tr("Mainstrings", "excess_x_items_left", p1, p2, p3)
  }
  /// Experience
  public static var experience: String { return L10n.tr("Mainstrings", "experience") }
  /// Experience points represent your progress and allow you to level up. You’ll mainly **gain EXP** from completing tasks or quests, but there are also some class skills that give EXP.\n\nTasks of higher difficulty, or red-colored tasks will give you **more EXP**. The **Intelligence stat** also raises your rate of EXP gain.
  public static var experienceDescription: String { return L10n.tr("Mainstrings", "experience_description") }
  /// Experience Points
  public static var experiencePoints: String { return L10n.tr("Mainstrings", "experience_points") }
  /// Every Pet has a specific food they enjoy! Experiment to find out which will grow your Pet the fastest
  public static var fedPetDescription: String { return L10n.tr("Mainstrings", "fedPetDescription") }
  /// Fed a Pet
  public static var fedPetTitle: String { return L10n.tr("Mainstrings", "fedPetTitle") }
  /// Complete tasks to get food! You can feed it to your pet from Pets & Mounts
  public static var feedPetDescription: String { return L10n.tr("Mainstrings", "feedPet_description") }
  /// Feed a Pet
  public static var feedPetTitle: String { return L10n.tr("Mainstrings", "feedPet_title") }
  /// Filter
  public static var filter: String { return L10n.tr("Mainstrings", "filter") }
  /// Filter by Tags
  public static var filterByTags: String { return L10n.tr("Mainstrings", "filter_by_tags") }
  /// Finish
  public static var finish: String { return L10n.tr("Mainstrings", "finish") }
  /// Completing tasks gives you a chance to find eggs, hatching potions, and pet food.
  public static var firstDropExplanation1: String { return L10n.tr("Mainstrings", "first_drop_explanation1") }
  /// Head to your Items and try combining your new Egg and Hatching Potion!
  public static var firstDropExplanation2: String { return L10n.tr("Mainstrings", "first_drop_explanation2") }
  /// You found new items!
  public static var firstDropTitle: String { return L10n.tr("Mainstrings", "first_drop_title") }
  /// 5 Achievements
  public static var fiveAchievements: String { return L10n.tr("Mainstrings", "five_achievements") }
  /// Flower
  public static var flower: String { return L10n.tr("Mainstrings", "flower") }
  /// Food
  public static var food: String { return L10n.tr("Mainstrings", "food") }
  /// Food
  public static var foodSingular: String { return L10n.tr("Mainstrings", "food_singular") }
  /// Force Start
  public static var forceStart: String { return L10n.tr("Mainstrings", "force_start") }
  /// Friday
  public static var friday: String { return L10n.tr("Mainstrings", "friday") }
  /// Game Mechanics
  public static var gameMechanics: String { return L10n.tr("Mainstrings", "game_mechanics") }
  /// Gems allow you to buy fun extras for your account, including:
  public static var gemBenefitsTitle: String { return L10n.tr("Mainstrings", "gem_benefits_title") }
  /// %d Gem cap
  public static func gemCap(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "gem_cap", p1)
  }
  /// Gems
  public static var gems: String { return L10n.tr("Mainstrings", "gems") }
  /// Gems are a currency purchased with real money that allow you to buy extra content within Habitica and are one of the main sources of financial support for the Habitica team alongside subscriptions.\n\nAll content purchased through Gems is purely cosmetic or can be obtained for free with time.\n\nYou can also receive Gems through gifts from other players, Challenge prizes, contributing to Habitica, or subscribing.
  public static var gemsDescription: String { return L10n.tr("Mainstrings", "gems_description") }
  /// Purchasing Gems supports our small team and helps keep Habitica running
  public static var gemsSupportDevelopers: String { return L10n.tr("Mainstrings", "gems_support_developers") }
  /// Get more out of Habitica
  public static var getMoreHabitica: String { return L10n.tr("Mainstrings", "get_more_habitica") }
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
  /// Gift Gems
  public static var giftGems: String { return L10n.tr("Mainstrings", "gift_gems") }
  /// Enter recipient's @username
  public static var giftGemsAlertPrompt: String { return L10n.tr("Mainstrings", "gift_gems_alert_prompt") }
  /// Who would you like to send your gift to?
  public static var giftGemsAlertTitle: String { return L10n.tr("Mainstrings", "gift_gems_alert_title") }
  /// Habitica will never require you to gift gems to other players. Begging people for gems is a violation of the Community Guidelines and should be reported to admin@habitica.com.
  public static var giftGemsDisclaimer: String { return L10n.tr("Mainstrings", "gift_gems_disclaimer") }
  /// Enter how many of your Gems you’d like to gift or switch tabs to purchase Gems to gift
  public static var giftGemsExplanationBalance: String { return L10n.tr("Mainstrings", "gift_gems_explanation_balance") }
  /// Choose how many Gems to gift below or switch tabs to gift Gems from your current balance
  public static var giftGemsExplanationPurchase: String { return L10n.tr("Mainstrings", "gift_gems_explanation_purchase") }
  /// Want to bestow a shiny haul of Gems to someone else?
  public static var giftGemsPrompt: String { return L10n.tr("Mainstrings", "gift_gems_prompt") }
  /// Gift a sub and get a sub free event going on now!
  public static var giftOneGetOne: String { return L10n.tr("Mainstrings", "gift_one_get_one") }
  /// Gift a subscription now and you’ll get the same sub for yourself free!
  public static var giftOneGetOneDescription: String { return L10n.tr("Mainstrings", "gift_one_get_one_description") }
  /// Gift One, Get One Event
  public static var giftOneGetOneTitle: String { return L10n.tr("Mainstrings", "gift_one_get_one_title") }
  /// Enter recipient's @ username
  public static var giftRecipientSubtitle: String { return L10n.tr("Mainstrings", "gift_recipient_subtitle") }
  /// Who would you like to gift to?
  public static var giftRecipientTitle: String { return L10n.tr("Mainstrings", "gift_recipient_title") }
  /// Your gift was sent!
  public static var giftSentConfirmation: String { return L10n.tr("Mainstrings", "gift_sent_confirmation") }
  /// You sent %@:
  public static func giftSentTo(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "gift_sent_to", p1)
  }
  /// Gift Subscription
  public static var giftSubscription: String { return L10n.tr("Mainstrings", "gift_subscription") }
  /// Choose the subscription you’d like to gift below! This purchase won’t automatically renew.
  public static var giftSubscriptionPrompt: String { return L10n.tr("Mainstrings", "gift_subscription_prompt") }
  /// Glasses
  public static var glasses: String { return L10n.tr("Mainstrings", "glasses") }
  /// Go Shopping
  public static var goShopping: String { return L10n.tr("Mainstrings", "go_shopping") }
  /// Go to Items
  public static var goToItems: String { return L10n.tr("Mainstrings", "go_to_items") }
  /// Gold
  public static var gold: String { return L10n.tr("Mainstrings", "gold") }
  /// Gold is the **main form of currency** within Habitica and allows you to buy certain gear, quests, items, or even custom rewards you make for yourself.\n\n**Earn Gold** through completing tasks or quests, or through some Class skills. Higher **Perception stats** raise the amount of Gold you earn.\n\nIf you subscribe to Habitica, you can even use Gold to purchase a number of Gems determined by the length of time you’ve been subscribed.
  public static var goldDescription: String { return L10n.tr("Mainstrings", "gold_description") }
  /// Great
  public static var great: String { return L10n.tr("Mainstrings", "great") }
  /// Grey
  public static var grey: String { return L10n.tr("Mainstrings", "grey") }
  /// Group By
  public static var groupBy: String { return L10n.tr("Mainstrings", "group_by") }
  /// Group Plan
  public static var groupPlan: String { return L10n.tr("Mainstrings", "group_plan") }
  /// Ventured into the social side of Habitica by joining a Guild!
  public static var guildJoinedDescription: String { return L10n.tr("Mainstrings", "guildJoinedDescription") }
  /// Joined a Guild
  public static var guildJoinedTitle: String { return L10n.tr("Mainstrings", "guildJoinedTitle") }
  /// Hatch
  public static var hatch: String { return L10n.tr("Mainstrings", "hatch") }
  /// Use on Egg
  public static var hatchEgg: String { return L10n.tr("Mainstrings", "hatch_egg") }
  /// Hatch Pet
  public static var hatchPet: String { return L10n.tr("Mainstrings", "hatch_pet") }
  /// Hatch Pet again
  public static var hatchPetAgain: String { return L10n.tr("Mainstrings", "hatch_pet_again") }
  /// Complete tasks to get a Hatching Potion and Egg then hatch your Pet!
  public static var hatchPetDescription: String { return L10n.tr("Mainstrings", "hatch_pet_description") }
  /// Hatch a Pet
  public static var hatchPetTitle: String { return L10n.tr("Mainstrings", "hatch_pet_title") }
  /// Hatch with potion
  public static var hatchPotion: String { return L10n.tr("Mainstrings", "hatch_potion") }
  /// There are so many Pets to collect, you’re bound to have a favorite. If you feed them, they may just grow…
  public static var hatchedPetDescription: String { return L10n.tr("Mainstrings", "hatchedPetDescription") }
  /// Hatched a Pet
  public static var hatchedPetTitle: String { return L10n.tr("Mainstrings", "hatchedPetTitle") }
  /// Hatching Potion
  public static var hatchingPotion: String { return L10n.tr("Mainstrings", "hatching_potion") }
  /// Hatching Potions
  public static var hatchingPotions: String { return L10n.tr("Mainstrings", "hatching_potions") }
  /// Headband
  public static var headband: String { return L10n.tr("Mainstrings", "headband") }
  /// Health
  public static var health: String { return L10n.tr("Mainstrings", "health") }
  /// This represents your avatar’s life. Missing a Daily or doing a negative Habit **reduces your HP**.\n\n**Regain HP** by leveling up, using a Health Potion, or a class skill with healing ability.\n\nIf your **HP reaches 0** you will lose a level, all Gold, and one piece of equipment. Lost equipment can be re-purchased.
  public static var healthDescription: String { return L10n.tr("Mainstrings", "health_description") }
  /// Health Points
  public static var healthPoints: String { return L10n.tr("Mainstrings", "health_points") }
  /// +%d Mystic Hourglass
  public static func hourglassCount(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "hourglass_count", p1)
  }
  /// Mystic Hourglasses are an extremely rare form of currency you can only receive for subscribing to Habitica for three consecutive months or more. They are used in the Time Traveler’s shop to buy past gear sets, pets, mounts, animated backgrounds, or even special quests.\n\nYou can receive up to four Mystic Hourglasses a year. The time they are rewarded is based on your subscription renewal schedule. They are sent out on the first day of a new month after your last subscription payment that qualified you for an hourglass. See the [Subscription] page for more details.
  public static var hourglassesDescription: String { return L10n.tr("Mainstrings", "hourglasses_description") }
  /// 100 Gold
  public static var hundredGold: String { return L10n.tr("Mainstrings", "hundred_gold") }
  /// Inactive
  public static var inactive: String { return L10n.tr("Mainstrings", "inactive") }
  /// You’ll need more Mystic Hourglasses to buy this item! Hourglasses are rewarded for being subscribed for consecutive months.
  public static var insufficientHourglassesMessage: String { return L10n.tr("Mainstrings", "insufficient_hourglasses_message") }
  /// You’ll need more Mystic Hourglasses to buy this item! Stay Subscribed to keep receiving your Hourglasses.
  public static var insufficientHourglassesMessageSubscriber: String { return L10n.tr("Mainstrings", "insufficient_hourglasses_message_subscriber") }
  /// You have to specify a valid Habitica Username as recipient.
  public static var invalidRecipientMessage: String { return L10n.tr("Mainstrings", "invalid_recipient_message") }
  /// Invalid Habitica Username
  public static var invalidRecipientTitle: String { return L10n.tr("Mainstrings", "invalid_recipient_title") }
  /// Invitations
  public static var invitations: String { return L10n.tr("Mainstrings", "invitations") }
  /// Invite Party
  public static var inviteParty: String { return L10n.tr("Mainstrings", "invite_party") }
  /// You invited a friend (or friends) who joined you on your adventure!
  public static var invitedFriendDescription: String { return L10n.tr("Mainstrings", "invitedFriendDescription") }
  /// Invited a Friend
  public static var invitedFriendTitle: String { return L10n.tr("Mainstrings", "invitedFriendTitle") }
  /// Join
  public static var join: String { return L10n.tr("Mainstrings", "join") }
  /// Join Challenge
  public static var joinChallenge: String { return L10n.tr("Mainstrings", "join_challenge") }
  /// Joined Challenge
  public static var joinedChallenge: String { return L10n.tr("Mainstrings", "joined_challenge") }
  /// Keep Tasks
  public static var keepTasks: String { return L10n.tr("Mainstrings", "keep_tasks") }
  /// Keep %d Tasks
  public static func keepXTasks(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "keep_x_tasks", p1)
  }
  /// Known Issues
  public static var knownIssues: String { return L10n.tr("Mainstrings", "known_issues") }
  /// Last Activity %@
  public static func lastActivity(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "last_activity", p1)
  }
  /// Leader
  public static var leader: String { return L10n.tr("Mainstrings", "leader") }
  /// Learn More
  public static var learnMore: String { return L10n.tr("Mainstrings", "learn_more") }
  /// Leave
  public static var leave: String { return L10n.tr("Mainstrings", "leave") }
  /// Leave & Delete Task
  public static var leaveAndDeleteTask: String { return L10n.tr("Mainstrings", "leave_and_delete_task") }
  /// Leave & Delete Tasks
  public static var leaveAndDeleteTasks: String { return L10n.tr("Mainstrings", "leave_and_delete_tasks") }
  /// Leave & Delete %d Tasks
  public static func leaveAndDeleteXTasks(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "leave_and_delete_x_tasks", p1)
  }
  /// Leave & Keep Tasks
  public static var leaveAndKeepTasks: String { return L10n.tr("Mainstrings", "leave_and_keep_tasks") }
  /// Leave Challenge
  public static var leaveChallenge: String { return L10n.tr("Mainstrings", "leave_challenge") }
  /// Do you want to leave the Challenge and keep or delete the tasks?
  public static var leaveChallengePrompt: String { return L10n.tr("Mainstrings", "leave_challenge_prompt") }
  /// Leave Challenge?
  public static var leaveChallengeTitle: String { return L10n.tr("Mainstrings", "leave_challenge_title") }
  /// Left Challenge
  public static var leftChallenge: String { return L10n.tr("Mainstrings", "left_challenge") }
  /// Level
  public static var level: String { return L10n.tr("Mainstrings", "level") }
  /// Level %d
  public static func levelNumber(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "level_number", p1)
  }
  /// By accomplishing your real life goals, you leveled up and are now fully healed!
  public static var levelupDescription: String { return L10n.tr("Mainstrings", "levelup_description") }
  /// I got to level %ld in Habitica by improving my real-life habits!
  public static func levelupShare(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "levelup_share", p1)
  }
  /// You Reached Level %ld!
  public static func levelupTitle(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "levelup_title", p1)
  }
  /// Limited Event
  public static var limitedEvent: String { return L10n.tr("Mainstrings", "limited_event") }
  /// Magic Potion
  public static var magicPotion: String { return L10n.tr("Mainstrings", "magic_potion") }
  /// Magic Potions
  public static var magicPotions: String { return L10n.tr("Mainstrings", "magic_potions") }
  /// Mana
  public static var mana: String { return L10n.tr("Mainstrings", "mana") }
  /// Mana points are unlocked with the class system at level 10 and allow you to **use Skills** once you begin learning them at level 11.\n\nSome **MP is restored** at day reset every day, but you can regain more by completing tasks or using a Mage class skill.
  public static var manaDescription: String { return L10n.tr("Mainstrings", "mana_description") }
  /// Mana Points
  public static var manaPoints: String { return L10n.tr("Mainstrings", "mana_points") }
  /// Sometimes the app won’t automatically sync content or gets stuck with some odd behavior. Pull to refresh or force close the app and reopen it to see if it helps
  public static var manualSyncDescription: String { return L10n.tr("Mainstrings", "manual_sync_description") }
  /// Manual Sync & Force Restart
  public static var manualSyncTitle: String { return L10n.tr("Mainstrings", "manual_sync_title") }
  /// Member of a Group Plan
  public static var memberGroupPlan: String { return L10n.tr("Mainstrings", "member_group_plan") }
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
  /// You’ll need more Gems to buy this item!
  public static var moreGemsMessage: String { return L10n.tr("Mainstrings", "more_gems_message") }
  /// Report a Bug
  public static var moreHelpButton: String { return L10n.tr("Mainstrings", "more_help_button") }
  /// Send a report to us and we’ll get back to you!
  public static var moreHelpDescription: String { return L10n.tr("Mainstrings", "more_help_description") }
  /// Need more help?
  public static var moreHelpTitle: String { return L10n.tr("Mainstrings", "more_help_title") }
  /// More Options
  public static var moreOptions: String { return L10n.tr("Mainstrings", "more_options") }
  /// Post a message in the [Habitica Help Guild](https://habitica.com/groups/guild/5481ccf3-5d2d-48a9-a871-70a7380cee5a) to have your questions answered by a fellow player
  public static var moreQuestionsText: String { return L10n.tr("Mainstrings", "more_questions_text") }
  /// Still have a question?
  public static var moreQuestionsTitle: String { return L10n.tr("Mainstrings", "more_questions_title") }
  /// You have earned the “Mount Master” achievement for taming all the mounts!
  public static var mountMasterDescription: String { return L10n.tr("Mainstrings", "mountMasterDescription") }
  /// Mount Master
  public static var mountMasterTitle: String { return L10n.tr("Mainstrings", "mountMasterTitle") }
  /// Mounts
  public static var mounts: String { return L10n.tr("Mainstrings", "mounts") }
  /// My Challenges
  public static var myChallenges: String { return L10n.tr("Mainstrings", "my_challenges") }
  /// My Guilds
  public static var myGuilds: String { return L10n.tr("Mainstrings", "my_guilds") }
  /// Mystery Sets
  public static var mysterySets: String { return L10n.tr("Mainstrings", "mystery_sets") }
  /// Mystic Hourglasses
  public static var mysticHourglasses: String { return L10n.tr("Mainstrings", "mystic_hourglasses") }
  /// Name
  public static var name: String { return L10n.tr("Mainstrings", "name") }
  /// Never
  public static var never: String { return L10n.tr("Mainstrings", "never") }
  /// never
  public static var neverLowerCase: String { return L10n.tr("Mainstrings", "never_lower_case") }
  /// New Message
  public static var newMessage: String { return L10n.tr("Mainstrings", "new_message") }
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
  /// Not Recurring
  public static var notRecurring: String { return L10n.tr("Mainstrings", "not_recurring") }
  /// Notes
  public static var notes: String { return L10n.tr("Mainstrings", "notes") }
  /// OK
  public static var ok: String { return L10n.tr("Mainstrings", "ok") }
  /// Onboarding Tasks
  public static var onboardingTasks: String { return L10n.tr("Mainstrings", "onboarding_tasks") }
  /// You completed your OnboardingTasks!
  public static var onboardingCompleteAchievementTitle: String { return L10n.tr("Mainstrings", "onboardingComplete_achievement_title") }
  /// If you want even more, check out Achievements and start collecting!
  public static var onboardingCompleteDescription: String { return L10n.tr("Mainstrings", "onboardingCompleteDescription") }
  /// You earned 5 Achievements and 100 Gold for your efforts.
  public static var onboardingCompleteTitle: String { return L10n.tr("Mainstrings", "onboardingCompleteTitle") }
  /// 1 Filter
  public static var oneFilter: String { return L10n.tr("Mainstrings", "one_filter") }
  /// 1 Month
  public static var oneMonth: String { return L10n.tr("Mainstrings", "one_month") }
  /// Onwards
  public static var onwards: String { return L10n.tr("Mainstrings", "onwards") }
  /// Open
  public static var `open`: String { return L10n.tr("Mainstrings", "open") }
  /// Open App Store Page
  public static var openAppStore: String { return L10n.tr("Mainstrings", "open_app_store") }
  /// Open Apple ID Subscriptions
  public static var openItunes: String { return L10n.tr("Mainstrings", "open_itunes") }
  /// Open Website
  public static var openWebsite: String { return L10n.tr("Mainstrings", "open_website") }
  /// Organize By
  public static var organizeBy: String { return L10n.tr("Mainstrings", "organize_by") }
  /// Your party grew to 4 members!
  public static var partyOnDescription: String { return L10n.tr("Mainstrings", "partyOnDescription") }
  /// Party On
  public static var partyOnTitle: String { return L10n.tr("Mainstrings", "partyOnTitle") }
  /// You teamed up with a party member!
  public static var partyUpDescription: String { return L10n.tr("Mainstrings", "partyUpDescription") }
  /// Party Up
  public static var partyUpTitle: String { return L10n.tr("Mainstrings", "partyUpTitle") }
  /// Password
  public static var password: String { return L10n.tr("Mainstrings", "password") }
  /// Pause Damage
  public static var pauseDamage: String { return L10n.tr("Mainstrings", "pause_damage") }
  /// Pending damage
  public static var pendingDamage: String { return L10n.tr("Mainstrings", "pending_damage") }
  /// %d%% Complete
  public static func percentComplete(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "percent_complete", p1)
  }
  /// %@, Mount Owned
  public static func petAccessibilityLabelMountOwned(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "pet_accessibility_label_mount_owned", p1)
  }
  /// %@, Raised %d%%
  public static func petAccessibilityLabelRaised(_ p1: String, _ p2: Int) -> String {
    return L10n.tr("Mainstrings", "pet_accessibility_label_raised", p1, p2)
  }
  /// Pets
  public static var pets: String { return L10n.tr("Mainstrings", "pets") }
  /// Photo URL
  public static var photoUrl: String { return L10n.tr("Mainstrings", "photo_url") }
  /// Pin
  public static var pin: String { return L10n.tr("Mainstrings", "pin") }
  /// Plain Backgrounds
  public static var plainBackgrounds: String { return L10n.tr("Mainstrings", "plain_backgrounds") }
  /// Ponytail
  public static var ponytail: String { return L10n.tr("Mainstrings", "ponytail") }
  /// Premium Currency
  public static var premiumCurrency: String { return L10n.tr("Mainstrings", "premium_currency") }
  /// How it works
  public static var promoInfoInstructionsTitle: String { return L10n.tr("Mainstrings", "promo_info_instructions_title") }
  /// Limitations
  public static var promoInfoLimitationsTitle: String { return L10n.tr("Mainstrings", "promo_info_limitations_title") }
  /// Publish Challenge
  public static var publishChallenge: String { return L10n.tr("Mainstrings", "publish_challenge") }
  /// Purchase Customization
  public static var purchaseCustomization: String { return L10n.tr("Mainstrings", "purchase_customization") }
  /// Equipment is a way to customize your avatar and improve your stats
  public static var purchaseEquipmentDescription: String { return L10n.tr("Mainstrings", "purchase_equipment_description") }
  /// Purchase Equipment
  public static var purchaseEquipmentTitle: String { return L10n.tr("Mainstrings", "purchase_equipment_title") }
  /// Purchase for %d Gems
  public static func purchaseForGems(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "purchase_for_gems", p1)
  }
  /// You can purchase this customization from the Time Travelers shop
  public static var purchaseFromTimeTravelersShop: String { return L10n.tr("Mainstrings", "purchase_from_time_travelers_shop") }
  /// Purchase Gems
  public static var purchaseGems: String { return L10n.tr("Mainstrings", "purchase_gems") }
  /// Purchase %d
  public static func purchaseX(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "purchase_x", p1)
  }
  /// You purchased %@
  public static func purchased(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "purchased", p1)
  }
  /// Equipment can be practical or just fashionable. Raise your stats to get all sorts of benefits to your avatar
  public static var purchasedEquipmentDescription: String { return L10n.tr("Mainstrings", "purchasedEquipmentDescription") }
  /// Purchased Equipment
  public static var purchasedEquipmentTitle: String { return L10n.tr("Mainstrings", "purchasedEquipmentTitle") }
  /// Quest
  public static var quest: String { return L10n.tr("Mainstrings", "quest") }
  /// Quest Completed!
  public static var questCompletedTitle: String { return L10n.tr("Mainstrings", "quest_completed_title") }
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
  /// Remove
  public static var remove: String { return L10n.tr("Mainstrings", "remove") }
  /// Renew Subscription
  public static var renewSubscription: String { return L10n.tr("Mainstrings", "renew_subscription") }
  /// Want to continue your benefits? You can start a new subscription before this one runs out to keep your benefits active.
  public static var renewSubscriptionDescription: String { return L10n.tr("Mainstrings", "renew_subscription_description") }
  /// Want to continue your benefits? You can start a new subscription before your gifted one runs out to keep your benefits active.
  public static var renewSubscriptionGiftedDescription: String { return L10n.tr("Mainstrings", "renew_subscription_gifted_description") }
  /// Repeat Password
  public static var repeatPassword: String { return L10n.tr("Mainstrings", "repeat_password") }
  /// Reply
  public static var reply: String { return L10n.tr("Mainstrings", "reply") }
  /// Report %@ for violation?
  public static func reportXViolation(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "report_x_violation", p1)
  }
  /// Reset Tutorials
  public static var resetTips: String { return L10n.tr("Mainstrings", "reset_tips") }
  /// Reset Streak
  public static var resetStreak: String { return L10n.tr("Mainstrings", "resetStreak") }
  /// Resubscribe
  public static var resubscribe: String { return L10n.tr("Mainstrings", "resubscribe") }
  /// Resume Damage
  public static var resumeDamage: String { return L10n.tr("Mainstrings", "resume_damage") }
  /// Resync
  public static var resync: String { return L10n.tr("Mainstrings", "resync") }
  /// Resync all
  public static var resyncAll: String { return L10n.tr("Mainstrings", "resync_all") }
  /// Resync this task
  public static var resyncTask: String { return L10n.tr("Mainstrings", "resync_task") }
  /// Sale
  public static var sale: String { return L10n.tr("Mainstrings", "sale") }
  /// Saturday
  public static var saturday: String { return L10n.tr("Mainstrings", "saturday") }
  /// Save
  public static var save: String { return L10n.tr("Mainstrings", "save") }
  /// Search
  public static var search: String { return L10n.tr("Mainstrings", "search") }
  /// Sell for %d Gold
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
  /// Show Details
  public static var showDetails: String { return L10n.tr("Mainstrings", "show_details") }
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
  /// Stat Allocation
  public static var statAllocation: String { return L10n.tr("Mainstrings", "stat_allocation") }
  /// All Habitica characters have four stats that affect the gameplay aspects of Habitica.\n\n**Strength (STR)** affects critical hits and raises damage done to a Quest Boss. Warriors and Rogues gain STR from their class equipment.\n\n**Constitution (CON)** raises your HP and makes you take less damage. Healers and Warriors gain CON from their class equipment.\n\n**Intelligence (INT)** raises the amount of EXP you earn and gives you more Mana. Mages and Healers gain INT from their class equipment.\n\n**Perception (PER)** increases the gold you earn and the rate of finding dropped items. Rogues and Mages gain PER from their class equipment.\n\nAfter level 10, you earn 1 Stat Point every level you gain that you can put into any stat you’d like. You can also equip gear that has different combinations of stat boosts.
  public static var statDescription: String { return L10n.tr("Mainstrings", "stat_description") }
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
  /// Want more than 2 weeks of data?
  public static var subscribeForTaskHistory: String { return L10n.tr("Mainstrings", "subscribe_for_task_history") }
  /// Subscriber Currency
  public static var subscriberCurrency: String { return L10n.tr("Mainstrings", "subscriber_currency") }
  /// Subscription
  public static var subscription: String { return L10n.tr("Mainstrings", "subscription") }
  /// Become a subscriber and you’ll get these useful benefits
  public static var subscriptionBenefitsTitle: String { return L10n.tr("Mainstrings", "subscription_benefits_title") }
  /// You get these benefits for being a Subscriber
  public static var subscriptionBenefitsTitleSubscribed: String { return L10n.tr("Mainstrings", "subscription_benefits_title_subscribed") }
  /// Recurring every %@
  public static func subscriptionDuration(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "subscription_duration", p1)
  }
  /// Gift a Subscription
  public static var subscriptionGiftButton: String { return L10n.tr("Mainstrings", "subscription_gift_button") }
  /// Want to give the benefits of a subscription to someone else?
  public static var subscriptionGiftExplanation: String { return L10n.tr("Mainstrings", "subscription_gift_explanation") }
  /// You’ll be able to buy Gems from the Market for 20 gold each!
  public static var subscriptionInfo1Description: String { return L10n.tr("Mainstrings", "subscription_info_1_description") }
  /// Gold for Gems
  public static var subscriptionInfo1Title: String { return L10n.tr("Mainstrings", "subscription_info_1_title") }
  /// Earn Mystic Hourglasses to purchase items in the Time Traveler’s Shop!
  public static var subscriptionInfo2Description: String { return L10n.tr("Mainstrings", "subscription_info_2_description") }
  /// Mystic Hourglasses
  public static var subscriptionInfo2Title: String { return L10n.tr("Mainstrings", "subscription_info_2_title") }
  /// Subscribe now to get an exclusive set now and receive new items every month!
  public static var subscriptionInfo3Description: String { return L10n.tr("Mainstrings", "subscription_info_3_description") }
  /// Subscribe now to get this %@ set now and receive new items every month!
  public static func subscriptionInfo3DescriptionNew(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "subscription_info_3_description_new", p1)
  }
  /// Monthly Mystery Items
  public static var subscriptionInfo3Title: String { return L10n.tr("Mainstrings", "subscription_info_3_title") }
  /// Receive the Royal Purple Jackalope pet when you become a new subscriber.
  public static var subscriptionInfo4Description: String { return L10n.tr("Mainstrings", "subscription_info_4_description") }
  /// Monthly Mystery Items
  public static var subscriptionInfo4Title: String { return L10n.tr("Mainstrings", "subscription_info_4_title") }
  /// Discover even more items in Habitica with a 2x bonus daily drop cap.
  public static var subscriptionInfo5Description: String { return L10n.tr("Mainstrings", "subscription_info_5_description") }
  /// Double the Drops
  public static var subscriptionInfo5Title: String { return L10n.tr("Mainstrings", "subscription_info_5_title") }
  /// Choose the Subscription length that works for you
  public static var subscriptionOptionsTitle: String { return L10n.tr("Mainstrings", "subscription_options_title") }
  /// Become a Subscriber to buy Gems with gold, get monthly mystery items, increased drop caps and more!
  public static var subscriptionPromoDescription: String { return L10n.tr("Mainstrings", "subscription_promo_description") }
  /// Need Gems?
  public static var subscriptionPromoTitle: String { return L10n.tr("Mainstrings", "subscription_promo_title") }
  /// Subscribing supports our small team and helps keep Habitica running
  public static var subscriptionSupportDevelopers: String { return L10n.tr("Mainstrings", "subscription_support_developers") }
  /// success
  public static var success: String { return L10n.tr("Mainstrings", "success") }
  /// You need a %@ and %@ Potion to hatch this pet again
  public static func suggestPetHatchAgainMissingBoth(_ p1: String, _ p2: String) -> String {
    return L10n.tr("Mainstrings", "suggest_pet_hatch_again_missing_both", p1, p2)
  }
  /// You still need a %@ Egg to hatch this pet again
  public static func suggestPetHatchAgainMissingEgg(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "suggest_pet_hatch_again_missing_egg", p1)
  }
  /// You still need a %@ Potion to hatch this pet again
  public static func suggestPetHatchAgainMissingPotion(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "suggest_pet_hatch_again_missing_potion", p1)
  }
  /// You need a %@ and %@ Potion to hatch this pet
  public static func suggestPetHatchMissingBoth(_ p1: String, _ p2: String) -> String {
    return L10n.tr("Mainstrings", "suggest_pet_hatch_missing_both", p1, p2)
  }
  /// You still need a %@ Egg to hatch this pet
  public static func suggestPetHatchMissingEgg(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "suggest_pet_hatch_missing_egg", p1)
  }
  /// You still need a %@ Potion to hatch this pet
  public static func suggestPetHatchMissingPotion(_ p1: String) -> String {
    return L10n.tr("Mainstrings", "suggest_pet_hatch_missing_potion", p1)
  }
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
  /// Task History (Very Experimental)
  public static var taskHistory: String { return L10n.tr("Mainstrings", "task_history") }
  /// Welcome to the Inn! Pull up a chair to chat, or take a break from your tasks.
  public static var tavernIntroHeader: String { return L10n.tr("Mainstrings", "tavern_intro_header") }
  /// Teleporting to Habitica
  public static var teleportingHabitica: String { return L10n.tr("Mainstrings", "teleporting_habitica") }
  /// Thursday
  public static var thursday: String { return L10n.tr("Mainstrings", "thursday") }
  /// Time Travelers Backgrounds
  public static var timeTravelBackgrounds: String { return L10n.tr("Mainstrings", "time_travel_backgrounds") }
  /// Title
  public static var title: String { return L10n.tr("Mainstrings", "title") }
  /// Transfer
  public static var transfer: String { return L10n.tr("Mainstrings", "transfer") }
  /// Transfer Leadership
  public static var transferOwnership: String { return L10n.tr("Mainstrings", "transfer_ownership") }
  /// You have earned the “Triad Bingo” achievement for finding all the pets, taming all the mounts, and finding all the pets again!
  public static var triadBingoDescription: String { return L10n.tr("Mainstrings", "triadBingoDescription") }
  /// Triad Bingo
  public static var triadBingoTitle: String { return L10n.tr("Mainstrings", "triadBingoTitle") }
  /// Tuesday
  public static var tuesday: String { return L10n.tr("Mainstrings", "tuesday") }
  /// Two-Handed
  public static var twoHanded: String { return L10n.tr("Mainstrings", "twoHanded") }
  /// Un-block
  public static var unblockUser: String { return L10n.tr("Mainstrings", "unblock_user") }
  /// Unequip
  public static var unequip: String { return L10n.tr("Mainstrings", "unequip") }
  /// Unhatched Pet
  public static var unhatchedPet: String { return L10n.tr("Mainstrings", "unhatched_pet") }
  /// You've unlocked the Drop System! Now when you complete tasks, you have a small chance of finding an item, including eggs, potions, and food!
  public static var unlockDropsDescription: String { return L10n.tr("Mainstrings", "unlockDropsDescription") }
  /// You unlocked the drop system!
  public static var unlockDropsTitle: String { return L10n.tr("Mainstrings", "unlockDropsTitle") }
  /// Unlocks at level 10
  public static var unlocksLevelTen: String { return L10n.tr("Mainstrings", "unlocks_level_ten") }
  /// Unlocks after selecting a class
  public static var unlocksSelectingClass: String { return L10n.tr("Mainstrings", "unlocks_selecting_class") }
  /// Skills are unlocked once you reach level 10 and have selected a class
  public static var unlocksSelectingClassDescription: String { return L10n.tr("Mainstrings", "unlocks_selecting_class_description") }
  /// Now that you reached level 10, you can choose a class!
  public static var unlocksSelectingClassPrompt: String { return L10n.tr("Mainstrings", "unlocks_selecting_class_prompt") }
  /// Unpin
  public static var unpin: String { return L10n.tr("Mainstrings", "unpin") }
  /// No longer want to subscribe? You can manage your subscription from iTunes.
  public static var unsubscribeItunes: String { return L10n.tr("Mainstrings", "unsubscribe_itunes") }
  /// No longer want to subscribe? Due to your payment method, you can only unsubscribe through the website.
  public static var unsubscribeWebsite: String { return L10n.tr("Mainstrings", "unsubscribe_website") }
  /// We’re constantly pushing out new fixes, so be sure to check the App Store to see if there are any updates available
  public static var updateAppDescription: String { return L10n.tr("Mainstrings", "update_app_description") }
  /// Update the App
  public static var updateAppTitle: String { return L10n.tr("Mainstrings", "update_app_title") }
  /// Use
  public static var use: String { return L10n.tr("Mainstrings", "use") }
  /// This will take effect immediately after buying!
  public static var useImmediatelyDisclaimer: String { return L10n.tr("Mainstrings", "use_immediately_disclaimer") }
  /// You blocked %s.
  public static func userWasBlocked(_ p1: UnsafePointer<CChar>) -> String {
    return L10n.tr("Mainstrings", "user_was_blocked", p1)
  }
  /// You unblocked %s.
  public static func userWasUnblocked(_ p1: UnsafePointer<CChar>) -> String {
    return L10n.tr("Mainstrings", "user_was_unblocked", p1)
  }
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
  /// Usually %d Gems
  public static func usuallyXGems(_ p1: Int) -> String {
    return L10n.tr("Mainstrings", "usually_x_gems", p1)
  }
  /// View Achievements
  public static var viewAchievements: String { return L10n.tr("Mainstrings", "view_achievements") }
  /// View Gem Bundles
  public static var viewGemBundles: String { return L10n.tr("Mainstrings", "view_gem_bundles") }
  /// View Onboarding Tasks
  public static var viewOnboardingTasks: String { return L10n.tr("Mainstrings", "view_onboarding_tasks") }
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
  /// %@ to %@
  public static func xToY(_ p1: String, _ p2: String) -> String {
    return L10n.tr("Mainstrings", "x_to_y", p1, p2)
  }
  /// Yearly
  public static var yearly: String { return L10n.tr("Mainstrings", "yearly") }
  /// years
  public static var years: String { return L10n.tr("Mainstrings", "years") }
  /// You got an Achievement!
  public static var youGotAchievement: String { return L10n.tr("Mainstrings", "you_got_achievement") }
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
    /// Not owned
    public static var notOwned: String { return L10n.tr("Mainstrings", "accessibility.notOwned") }
    /// Owned
    public static var owned: String { return L10n.tr("Mainstrings", "accessibility.owned") }
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
    /// Unknown
    public static var unknown: String { return L10n.tr("Mainstrings", "accessibility.unknown") }
    /// Unknown Mount
    public static var unknownMount: String { return L10n.tr("Mainstrings", "accessibility.unknown_mount") }
    /// Unknown Pet
    public static var unknownPet: String { return L10n.tr("Mainstrings", "accessibility.unknown_pet") }
    /// View %@
    public static func viewX(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "accessibility.viewX", p1)
    }
    /// %@, World Boss, pending damage: %@
    public static func worldBossPendingDamage(_ p1: String, _ p2: String) -> String {
      return L10n.tr("Mainstrings", "accessibility.world_boss_pending_damage", p1, p2)
    }
    /// %d of %d
    public static func xofx(_ p1: Int, _ p2: Int) -> String {
      return L10n.tr("Mainstrings", "accessibility.xofx", p1, p2)
    }
  }

  public enum Achievements {
    /// Basic Achievements
    public static var basic: String { return L10n.tr("Mainstrings", "achievements.basic") }
    /// Onboarding Achievements
    public static var onboarding: String { return L10n.tr("Mainstrings", "achievements.onboarding") }
    /// Quests completed
    public static var quests: String { return L10n.tr("Mainstrings", "achievements.quests") }
    /// Seasonal Achievements
    public static var seasonal: String { return L10n.tr("Mainstrings", "achievements.seasonal") }
    /// Special Achievements
    public static var special: String { return L10n.tr("Mainstrings", "achievements.special") }
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

  public enum Empty {

    public enum Dailies {
      /// Dailies are tasks that repeat on a regular basis. Choose the schedule that works for you!
      public static var description: String { return L10n.tr("Mainstrings", "empty.dailies.description") }
      /// These are your Dailies
      public static var title: String { return L10n.tr("Mainstrings", "empty.dailies.title") }
    }

    public enum Habits {
      /// Habits don't have a rigid schedule. You can check them off multiple times per day.
      public static var description: String { return L10n.tr("Mainstrings", "empty.habits.description") }
      /// These are your Habits
      public static var title: String { return L10n.tr("Mainstrings", "empty.habits.title") }
    }

    public enum Inbox {
      /// Start chatting below! Remember to be friendly and follow the Community Guidelines.
      public static var description: String { return L10n.tr("Mainstrings", "empty.inbox.description") }
    }

    public enum Notifications {
      /// The notification fairies give you a raucous round of applause! Well done!
      public static var description: String { return L10n.tr("Mainstrings", "empty.notifications.description") }
      /// You're all caught up!
      public static var title: String { return L10n.tr("Mainstrings", "empty.notifications.title") }
    }

    public enum Rewards {
      /// Rewards are a great way to use Habitica and complete your tasks. Try adding a few today!
      public static var description: String { return L10n.tr("Mainstrings", "empty.rewards.description") }
      /// These are your Rewards
      public static var title: String { return L10n.tr("Mainstrings", "empty.rewards.title") }
    }

    public enum Todos {
      /// To Do's need to be completed once. Add checklists to your To Do's to increase their value.
      public static var description: String { return L10n.tr("Mainstrings", "empty.todos.description") }
      /// These are your To Do's
      public static var title: String { return L10n.tr("Mainstrings", "empty.todos.title") }
    }
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
    /// User not found.
    public static var userNotFound: String { return L10n.tr("Mainstrings", "errors.user_not_found") }
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

  public enum FallPromo {
    /// Between %s and %s, simply purchase any Gem bundle like usual and your account will be credited with the promotional amount of Gems. More Gems to spend, share, or save for any future releases!
    public static func infoInstructions(_ p1: UnsafePointer<CChar>, _ p2: UnsafePointer<CChar>) -> String {
      return L10n.tr("Mainstrings", "fall_promo.info_instructions", p1, p2)
    }
    /// The Fall Gala is in full swing so we thought it was the perfect time to introduce our first ever Gem Sale! Now you will get more Gems with each purchase than ever before.
    public static var infoPrompt: String { return L10n.tr("Mainstrings", "fall_promo.info_prompt") }
  }

  public enum GemsPromo {
    /// This promotion only applies during the limited time event. This event starts on %s (12:00 UTC) and will end %s (00:00 UTC). The promo offer is only available when buying Gems for yourself.
    public static func infoLimitations(_ p1: UnsafePointer<CChar>, _ p2: UnsafePointer<CChar>) -> String {
      return L10n.tr("Mainstrings", "gems_promo.info_limitations", p1, p2)
    }
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
    /// You have bought all the Gems you can this month. More become available within the first three days of each month. Thanks for subscribing!
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
    /// Time Travelers Shop
    public static var timeTravelersShop: String { return L10n.tr("Mainstrings", "locations.time_travelers_shop") }
  }

  public enum Login {
    /// There was an error with the authentication. Try again later
    public static var authenticationError: String { return L10n.tr("Mainstrings", "login.authentication_error") }
    /// Please enter a valid email.
    public static var emailInvalid: String { return L10n.tr("Mainstrings", "login.email_invalid") }
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
    /// Sign in with Apple
    public static var loginApple: String { return L10n.tr("Mainstrings", "login.login_apple") }
    /// Login with Facebook
    public static var loginFacebook: String { return L10n.tr("Mainstrings", "login.login_facebook") }
    /// Login with Google
    public static var loginGoogle: String { return L10n.tr("Mainstrings", "login.login_google") }
    /// Password and password confirmation have to match and be longer than 8 characters.
    public static var passwordConfirmError: String { return L10n.tr("Mainstrings", "login.password_confirm_error") }
    /// Register
    public static var register: String { return L10n.tr("Mainstrings", "login.register") }
    /// There was an issue with the request. Please check all data carefully.
    public static var registerError: String { return L10n.tr("Mainstrings", "login.register_error") }
    /// If we have your email on file, instructions for setting a new password have been sent to your email.
    public static var resetPasswordResponse: String { return L10n.tr("Mainstrings", "login.reset_password_response") }
    /// Login with %@
    public static func socialLogin(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "login.social_login", p1)
    }
    /// Register with %@
    public static func socialRegister(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "login.social_register", p1)
    }
  }

  public enum Member {
    /// Last logged in
    public static var lastLoggedIn: String { return L10n.tr("Mainstrings", "member.last_logged_in") }
    /// Member Since
    public static var memberSince: String { return L10n.tr("Mainstrings", "member.member_since") }
  }

  public enum Menu {
    /// Cast Skills
    public static var castSpells: String { return L10n.tr("Mainstrings", "menu.cast_spells") }
    /// Customize Avatar
    public static var customizeAvatar: String { return L10n.tr("Mainstrings", "menu.customize_avatar") }
    /// Purchase Gems
    public static var gems: String { return L10n.tr("Mainstrings", "menu.gems") }
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
    /// Subscription
    public static var subscription: String { return L10n.tr("Mainstrings", "menu.subscription") }
    /// Support
    public static var support: String { return L10n.tr("Mainstrings", "menu.support") }
  }

  public enum Notifications {
    /// Dismiss all
    public static var dismissAll: String { return L10n.tr("Mainstrings", "notifications.dismiss_all") }
    /// New Bailey Update!
    public static var newBailey: String { return L10n.tr("Mainstrings", "notifications.new_bailey") }
    /// You have new **Mystery Items**
    public static var newMysteryItem: String { return L10n.tr("Mainstrings", "notifications.new_mystery_item") }
    /// You were invited to join the Party **%s**
    public static func partyInvite(_ p1: UnsafePointer<CChar>) -> String {
      return L10n.tr("Mainstrings", "notifications.party_invite", p1)
    }
    /// You were invited to join the private guild **%s**
    public static func privateGuildInvite(_ p1: UnsafePointer<CChar>) -> String {
      return L10n.tr("Mainstrings", "notifications.private_guild_invite", p1)
    }
    /// You were invited to join the public guild **%s**
    public static func publicGuildInvite(_ p1: UnsafePointer<CChar>) -> String {
      return L10n.tr("Mainstrings", "notifications.public_guild_invite", p1)
    }
    /// You were invited to the Quest **%s**
    public static func questInvite(_ p1: UnsafePointer<CChar>) -> String {
      return L10n.tr("Mainstrings", "notifications.quest_invite", p1)
    }
    /// You have **%d unallocated Stat Points**
    public static func unallocatedStatPoints(_ p1: Int) -> String {
      return L10n.tr("Mainstrings", "notifications.unallocated_stat_points", p1)
    }
    /// **%@** has new posts.
    public static func unreadGuildMessage(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "notifications.unread_guild_message", p1)
    }
    /// Your party, **%@**, has new posts.
    public static func unreadPartyMessage(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "notifications.unread_party_message", p1)
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
    /// You are not participating
    public static var questNotParticipating: String { return L10n.tr("Mainstrings", "party.quest_not_participating") }
    /// %d/%d Members responded
    public static func questNumberResponded(_ p1: Int, _ p2: Int) -> String {
      return L10n.tr("Mainstrings", "party.quest_number_responded", p1, p2)
    }
    /// %d Participants
    public static func questParticipantCount(_ p1: Int) -> String {
      return L10n.tr("Mainstrings", "party.quest_participant_count", p1)
    }
    /// Remove from Party
    public static var removeFromParty: String { return L10n.tr("Mainstrings", "party.remove_from_party") }
    /// Are you sure you want to remove %@ from the party?
    public static func removeMemberTitle(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "party.remove_member_title", p1)
    }
    /// Start a Quest
    public static var startQuest: String { return L10n.tr("Mainstrings", "party.start_quest") }
    /// This will make %@ the new Party leader
    public static func transferOwnershipDescription(_ p1: String) -> String {
      return L10n.tr("Mainstrings", "party.transfer_ownership_description", p1)
    }
    /// Transfer Leadership?
    public static var transferOwnershipTitle: String { return L10n.tr("Mainstrings", "party.transfer_ownership_title") }
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
    /// Unlock by inviting friends to your party
    public static var unlockInvite: String { return L10n.tr("Mainstrings", "quests.unlock_invite") }
    /// Invite Friends
    public static var unlockInviteShort: String { return L10n.tr("Mainstrings", "quests.unlock_invite_short") }
    /// Unlock by reaching level %d
    public static func unlockLevel(_ p1: Int) -> String {
      return L10n.tr("Mainstrings", "quests.unlock_level", p1)
    }
    /// Level %d
    public static func unlockLevelShort(_ p1: Int) -> String {
      return L10n.tr("Mainstrings", "quests.unlock_level_short", p1)
    }
    /// Unlock by finishing Quest %d
    public static func unlockPrevious(_ p1: Int) -> String {
      return L10n.tr("Mainstrings", "quests.unlock_previous", p1)
    }
    /// Finish Quest %d
    public static func unlockPreviousShort(_ p1: Int) -> String {
      return L10n.tr("Mainstrings", "quests.unlock_previous_short", p1)
    }
  }

  public enum Settings {
    /// Add Email and Password authentication
    public static var addEmailAndPassword: String { return L10n.tr("Mainstrings", "settings.add_email_and_password") }
    /// Successfully added email and password
    public static var addedLocalAuth: String { return L10n.tr("Mainstrings", "settings.added_local_auth") }
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
    /// This will delete your account forever, and it can never be restored! Banked or spent Gems will not be refunded. If you’re absolutely certain, type your password into the text box below.
    public static var deleteAccountDescription: String { return L10n.tr("Mainstrings", "settings.delete_account_description") }
    /// This will delete your account forever, and it can never be restored! Banked or spent Gems will not be refunded. If you’re absolutely certain, type DELETE into the text box below.
    public static var deleteAccountDescriptionSocial: String { return L10n.tr("Mainstrings", "settings.delete_account_description_social") }
    /// Disable all Emails
    public static var disableAllEmails: String { return L10n.tr("Mainstrings", "settings.disable_all_emails") }
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
    /// Theme Mode
    public static var themeMode: String { return L10n.tr("Mainstrings", "settings.theme_mode") }
    /// User
    public static var user: String { return L10n.tr("Mainstrings", "settings.user") }
    /// Username not confirmed
    public static var usernameNotConfirmed: String { return L10n.tr("Mainstrings", "settings.username_not_confirmed") }
    /// Incorrect Password
    public static var wrongPassword: String { return L10n.tr("Mainstrings", "settings.wrong_password") }

    public enum EmailNotifications {
      /// Kicked from Group
      public static var bannedGroup: String { return L10n.tr("Mainstrings", "settings.email_notifications.banned_group") }
      /// Subscription Reminders
      public static var subscriptionReminders: String { return L10n.tr("Mainstrings", "settings.email_notifications.subscription_reminders") }
      /// Emails
      public static var title: String { return L10n.tr("Mainstrings", "settings.email_notifications.title") }
    }

    public enum PushNotifications {
      /// Gifted Gems
      public static var giftedGems: String { return L10n.tr("Mainstrings", "settings.push_notifications.gifted_gems") }
      /// Gifted Subscription
      public static var giftedSubscription: String { return L10n.tr("Mainstrings", "settings.push_notifications.gifted_subscription") }
      /// Important Announcements
      public static var importantAnnouncement: String { return L10n.tr("Mainstrings", "settings.push_notifications.important_announcement") }
      /// Invited to Guild
      public static var invitedGuid: String { return L10n.tr("Mainstrings", "settings.push_notifications.invited_guid") }
      /// Invited to Party
      public static var invitedParty: String { return L10n.tr("Mainstrings", "settings.push_notifications.invited_party") }
      /// Invited to Quest
      public static var invitedQuest: String { return L10n.tr("Mainstrings", "settings.push_notifications.invited_quest") }
      /// @Mentions in joined Guilds
      public static var mentionJoinedGuild: String { return L10n.tr("Mainstrings", "settings.push_notifications.mention_joined_guild") }
      /// @Mentions in Party
      public static var mentionParty: String { return L10n.tr("Mainstrings", "settings.push_notifications.mention_party") }
      /// @Mentions in not joined Guilds
      public static var mentionUnjoinedGuild: String { return L10n.tr("Mainstrings", "settings.push_notifications.mention_unjoined_guild") }
      /// Party Activity
      public static var partyActivity: String { return L10n.tr("Mainstrings", "settings.push_notifications.party_activity") }
      /// Your quest has begun
      public static var questBegun: String { return L10n.tr("Mainstrings", "settings.push_notifications.quest_begun") }
      /// Received private message
      public static var receivedPm: String { return L10n.tr("Mainstrings", "settings.push_notifications.received_pm") }
      /// Push Notifications
      public static var title: String { return L10n.tr("Mainstrings", "settings.push_notifications.title") }
      /// You won a challenge!
      public static var wonChallenge: String { return L10n.tr("Mainstrings", "settings.push_notifications.won_challenge") }
    }
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

  public enum SpookyPromo {
    /// Between %s and %s, simply purchase any Gem bundle like usual and your account will be credited with the promotional amount of Gems. More Gems to spend, share, or save for any future releases!
    public static func infoInstructions(_ p1: UnsafePointer<CChar>, _ p2: UnsafePointer<CChar>) -> String {
      return L10n.tr("Mainstrings", "spooky_promo.info_instructions", p1, p2)
    }
    /// The Gem Sale is back to haunt the very end of this year’s Fall Gala! This is one last chance to get more Gems than ever, so stock up while it lasts!
    public static var infoPrompt: String { return L10n.tr("Mainstrings", "spooky_promo.info_prompt") }
  }

  public enum Stable {
    /// Color
    public static var color: String { return L10n.tr("Mainstrings", "stable.color") }
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
    /// Type
    public static var type: String { return L10n.tr("Mainstrings", "stable.type") }
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

  public enum Support {
    /// Get Help
    public static var bugFixesButton: String { return L10n.tr("Mainstrings", "support.bug_fixes_button") }
    /// Did something go wrong? Check for answers here or reach out to us for help
    public static var bugFixesDescription: String { return L10n.tr("Mainstrings", "support.bug_fixes_description") }
    /// Bugs & Fixes
    public static var bugFixesTitle: String { return L10n.tr("Mainstrings", "support.bug_fixes_title") }
    /// Read More
    public static var questionsButton: String { return L10n.tr("Mainstrings", "support.questions_button") }
    /// We’ll explain the basics and answer common questions to get you up to speed
    public static var questionsDescription: String { return L10n.tr("Mainstrings", "support.questions_description") }
    /// Habitica Questions
    public static var questionsTitle: String { return L10n.tr("Mainstrings", "support.questions_title") }
    /// Submit Feedback
    public static var suggestionsButton: String { return L10n.tr("Mainstrings", "support.suggestions_button") }
    /// Have input on how features could work better or an idea for something new? Tell us!
    public static var suggestionsDescription: String { return L10n.tr("Mainstrings", "support.suggestions_description") }
    /// Suggestions & Feedback
    public static var suggestionsTitle: String { return L10n.tr("Mainstrings", "support.suggestions_title") }
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
    /// To Do
    public static var todo: String { return L10n.tr("Mainstrings", "tasks.todo") }
    /// To Do's
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
      /// You can either complete this To Do, edit it, or remove it.
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
        /// Attribute is %@
        public static func attribute(_ p1: String) -> String {
          return L10n.tr("Mainstrings", "tasks.form.accessibility.attribute", p1)
        }
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
        /// Change attribute to %@
        public static func setAttribute(_ p1: String) -> String {
          return L10n.tr("Mainstrings", "tasks.form.accessibility.set_attribute", p1)
        }
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
    /// Always Dark
    public static var alwaysDark: String { return L10n.tr("Mainstrings", "theme.alwaysDark") }
    /// Always Light
    public static var alwaysLight: String { return L10n.tr("Mainstrings", "theme.alwaysLight") }
    /// Blue
    public static var blue: String { return L10n.tr("Mainstrings", "theme.blue") }
    /// Dark
    public static var dark: String { return L10n.tr("Mainstrings", "theme.dark") }
    /// Default
    public static var defaultTheme: String { return L10n.tr("Mainstrings", "theme.default_theme") }
    /// Follow system setting
    public static var followSystem: String { return L10n.tr("Mainstrings", "theme.followSystem") }
    /// Green
    public static var green: String { return L10n.tr("Mainstrings", "theme.green") }
    /// Light
    public static var light: String { return L10n.tr("Mainstrings", "theme.light") }
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
    /// Achievements
    public static var achievements: String { return L10n.tr("Mainstrings", "titles.achievements") }
    /// API
    public static var api: String { return L10n.tr("Mainstrings", "titles.api") }
    /// Authentication
    public static var authentication: String { return L10n.tr("Mainstrings", "titles.authentication") }
    /// Avatar
    public static var avatar: String { return L10n.tr("Mainstrings", "titles.avatar") }
    /// Basics
    public static var basics: String { return L10n.tr("Mainstrings", "titles.basics") }
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
    /// Hall of Contributors
    public static var hallOfContributors: String { return L10n.tr("Mainstrings", "titles.hall_of_contributors") }
    /// Hall of Heroes
    public static var hallOfHeroes: String { return L10n.tr("Mainstrings", "titles.hall_of_heroes") }
    /// Hall of Patrons
    public static var hallOfPatrons: String { return L10n.tr("Mainstrings", "titles.hall_of_patrons") }
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
    /// Pets & Mounts
    public static var petsAndMounts: String { return L10n.tr("Mainstrings", "titles.pets_and_mounts") }
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
    /// Use To Do's to keep track of tasks you need to do just once.
    public static var todos1: String { return L10n.tr("Mainstrings", "tutorials.todos_1") }
    /// If your To Do has to be done by a certain time, set a due date. Looks like you can check one off — go ahead!
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
