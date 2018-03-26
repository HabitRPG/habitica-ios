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
  /// Monthly
  internal static let monthly = L10n.tr("Main", "monthly")
  /// Notes
  internal static let notes = L10n.tr("Main", "notes")
  /// Reset Justins Tips
  internal static let resetTips = L10n.tr("Main", "reset_tips")
  /// Reset Streak
  internal static let resetStreak = L10n.tr("Main", "resetStreak")
  /// Save
  internal static let save = L10n.tr("Main", "save")
  /// Search
  internal static let search = L10n.tr("Main", "search")
  /// Tags
  internal static let tags = L10n.tr("Main", "tags")
  /// Title
  internal static let title = L10n.tr("Main", "title")
  /// Weekly
  internal static let weekly = L10n.tr("Main", "weekly")
  /// Yearly
  internal static let yearly = L10n.tr("Main", "yearly")

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
