// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum L10n {
  /// Controls
  internal static let controls = L10n.tr("Main", "controls")
  /// Create
  internal static let create = L10n.tr("Main", "create")
  /// Daily
  internal static let daily = L10n.tr("Main", "daily")
  /// Difficulty
  internal static let difficulty = L10n.tr("Main", "difficulty")
  /// Discover
  internal static let discover = L10n.tr("Main", "discover")
  /// Last Activity %@
  internal static func lastActivity(_ p1: String) -> String {
    return L10n.tr("Main", "last_activity", p1)
  }
  /// Monthly
  internal static let monthly = L10n.tr("Main", "monthly")
  /// My Guilds
  internal static let myGuilds = L10n.tr("Main", "my_guilds")
  /// Notes
  internal static let notes = L10n.tr("Main", "notes")
  /// Reset Justins Tips
  internal static let resetTips = L10n.tr("Main", "reset_tips")
  /// Reset Streak
  internal static let resetStreak = L10n.tr("Main", "resetStreak")
  /// Resync
  internal static let resync = L10n.tr("Main", "resync")
  /// Resync all
  internal static let resyncAll = L10n.tr("Main", "resync_all")
  /// Resync this task
  internal static let resyncTask = L10n.tr("Main", "resync_task")
  /// Save
  internal static let save = L10n.tr("Main", "save")
  /// Search
  internal static let search = L10n.tr("Main", "search")
  /// Sync Error
  internal static let syncError = L10n.tr("Main", "sync_error")
  /// There was an error syncing some changes.
  internal static let syncErrorMessage = L10n.tr("Main", "sync_error_message")
  /// Tags
  internal static let tags = L10n.tr("Main", "tags")
  /// Title
  internal static let title = L10n.tr("Main", "title")
  /// Weekly
  internal static let weekly = L10n.tr("Main", "weekly")
  /// Yearly
  internal static let yearly = L10n.tr("Main", "yearly")

  internal enum Menu {
    /// About
    internal static let about = L10n.tr("Main", "menu.about")
    /// Cast Spells
    internal static let castSpells = L10n.tr("Main", "menu.cast_spells")
    /// Challenges
    internal static let challenges = L10n.tr("Main", "menu.challenges")
    /// Customize Avatar
    internal static let customizeAvatar = L10n.tr("Main", "menu.customize_avatar")
    /// Equipment
    internal static let equipment = L10n.tr("Main", "menu.equipment")
    /// Gems & Subscriptions
    internal static let gemsSubscriptions = L10n.tr("Main", "menu.gems_subscriptions")
    /// Guilds
    internal static let guilds = L10n.tr("Main", "menu.guilds")
    /// Help & FAQ
    internal static let helpFaq = L10n.tr("Main", "menu.help_faq")
    /// Inventory
    internal static let inventory = L10n.tr("Main", "menu.inventory")
    /// Items
    internal static let items = L10n.tr("Main", "menu.items")
    /// Mounts
    internal static let mounts = L10n.tr("Main", "menu.mounts")
    /// News
    internal static let news = L10n.tr("Main", "menu.news")
    /// Party
    internal static let party = L10n.tr("Main", "menu.party")
    /// Pets
    internal static let pets = L10n.tr("Main", "menu.pets")
    /// Select Class
    internal static let selectClass = L10n.tr("Main", "menu.select_class")
    /// Shops
    internal static let shops = L10n.tr("Main", "menu.shops")
    /// Social
    internal static let social = L10n.tr("Main", "menu.social")
    /// Stats
    internal static let stats = L10n.tr("Main", "menu.stats")
    /// Tavern
    internal static let tavern = L10n.tr("Main", "menu.tavern")
    /// Use Skills
    internal static let useSkills = L10n.tr("Main", "menu.use_skills")
  }

  internal enum Settings {
    /// API
    internal static let api = L10n.tr("Main", "settings.api")
    /// Authentication
    internal static let authentication = L10n.tr("Main", "settings.authentication")
    /// Change Class
    internal static let changeClass = L10n.tr("Main", "settings.change_class")
    /// Clear Cache
    internal static let clearCache = L10n.tr("Main", "settings.clear_cache")
    /// Custom Day Start
    internal static let customDayStart = L10n.tr("Main", "settings.custom_day_start")
    /// Daily Reminder
    internal static let dailyReminder = L10n.tr("Main", "settings.daily_reminder")
    /// Day Start
    internal static let dayStart = L10n.tr("Main", "settings.day_start")
    /// Disable all Push Notifications
    internal static let disableAllNotifications = L10n.tr("Main", "settings.disable_all_notifications")
    /// Disable Private Messages
    internal static let disablePm = L10n.tr("Main", "settings.disable_pm")
    /// Display NOtification Badge
    internal static let displayNotificationBadge = L10n.tr("Main", "settings.display_notification_badge")
    /// Every day at
    internal static let everyDay = L10n.tr("Main", "settings.every_day")
    /// Fix Character Values
    internal static let fixCharacterValues = L10n.tr("Main", "settings.fix_characterValues")
    /// Log Out
    internal static let logOut = L10n.tr("Main", "settings.log_out")
    /// Maintenance
    internal static let maintenance = L10n.tr("Main", "settings.maintenance")
    /// Notification Badge
    internal static let notificationBadge = L10n.tr("Main", "settings.notification_badge")
    /// Profile
    internal static let profile = L10n.tr("Main", "settings.profile")
    /// Push Notifications
    internal static let pushNotifications = L10n.tr("Main", "settings.push_notifications")
    /// Reload Content
    internal static let reloadContent = L10n.tr("Main", "settings.reload_content")
    /// Reminder
    internal static let reminder = L10n.tr("Main", "settings.reminder")
    /// Social
    internal static let social = L10n.tr("Main", "settings.social")
    /// User
    internal static let user = L10n.tr("Main", "settings.user")
  }

  internal enum Skills {
    /// Unlocks at level %d
    internal static func unlocksAt(_ p1: Int) -> String {
      return L10n.tr("Main", "skills.unlocks_at", p1)
    }
    /// You use %@
    internal static func useSkill(_ p1: String) -> String {
      return L10n.tr("Main", "skills.use_skill", p1)
    }
  }

  internal enum Stats {
    /// 0 Points to Allocate
    internal static let noPointsToAllocate = L10n.tr("Main", "stats.no_points_to_allocate")
    /// 1 Point to Allocate
    internal static let onePointToAllocate = L10n.tr("Main", "stats.one_point_to_allocate")
    /// %d Point to Allocate
    internal static func pointsToAllocate(_ p1: Int) -> String {
      return L10n.tr("Main", "stats.points_to_allocate", p1)
    }
  }

  internal enum Tasks {
    /// Daily
    internal static let daily = L10n.tr("Main", "tasks.daily")
    /// Habit
    internal static let habit = L10n.tr("Main", "tasks.habit")
    /// Reward
    internal static let reward = L10n.tr("Main", "tasks.reward")
    /// To-Do
    internal static let todo = L10n.tr("Main", "tasks.todo")

    internal enum Form {
      /// Checklist
      internal static let checklist = L10n.tr("Main", "tasks.form.checklist")
      /// Controls
      internal static let controls = L10n.tr("Main", "tasks.form.controls")
      /// Cost
      internal static let cost = L10n.tr("Main", "tasks.form.cost")
      /// New %@
      internal static func create(_ p1: String) -> String {
        return L10n.tr("Main", "tasks.form.create", p1)
      }
      /// What do you want to do regularly?
      internal static let dailiesTitlePlaceholder = L10n.tr("Main", "tasks.form.dailies_title_placeholder")
      /// Day of the month
      internal static let dayOfMonth = L10n.tr("Main", "tasks.form.day_of_month")
      /// Day of the week
      internal static let dayOfWeek = L10n.tr("Main", "tasks.form.day_of_week")
      /// Difficulty
      internal static let difficulty = L10n.tr("Main", "tasks.form.difficulty")
      /// Due date
      internal static let dueDate = L10n.tr("Main", "tasks.form.due_date")
      /// Edit %@
      internal static func edit(_ p1: String) -> String {
        return L10n.tr("Main", "tasks.form.edit", p1)
      }
      /// Every
      internal static let every = L10n.tr("Main", "tasks.form.every")
      /// What habits do you want to foster or break?
      internal static let habitTitlePlaceholder = L10n.tr("Main", "tasks.form.habit_title_placeholder")
      /// New checklist item
      internal static let newChecklistItem = L10n.tr("Main", "tasks.form.new_checklist_item")
      /// New reminder
      internal static let newReminder = L10n.tr("Main", "tasks.form.new_reminder")
      /// Include any notes to help you out
      internal static let notesPlaceholder = L10n.tr("Main", "tasks.form.notes_placeholder")
      /// Remind me
      internal static let remindMe = L10n.tr("Main", "tasks.form.remind_me")
      /// Reminders
      internal static let reminders = L10n.tr("Main", "tasks.form.reminders")
      /// Repeats
      internal static let repeats = L10n.tr("Main", "tasks.form.repeats")
      /// Reset Streak
      internal static let resetStreak = L10n.tr("Main", "tasks.form.reset_streak")
      /// How do you want to reward yourself?
      internal static let rewardsTitlePlaceholder = L10n.tr("Main", "tasks.form.rewards_title_placeholder")
      /// Scheduling
      internal static let scheduling = L10n.tr("Main", "tasks.form.scheduling")
      /// Start date
      internal static let startDate = L10n.tr("Main", "tasks.form.start_date")
      /// Tags
      internal static let tags = L10n.tr("Main", "tasks.form.tags")
      /// What do you want to complete once?
      internal static let todosTitlePlaceholder = L10n.tr("Main", "tasks.form.todos_title_placeholder")
    }
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
