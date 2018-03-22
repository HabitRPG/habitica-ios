// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
enum L10n {
  /// Controls
  static let controls = L10n.tr("Main", "controls")
  /// Create
  static let create = L10n.tr("Main", "create")
  /// Daily
  static let daily = L10n.tr("Main", "daily")
  /// Difficulty
  static let difficulty = L10n.tr("Main", "difficulty")
  /// Monthly
  static let monthly = L10n.tr("Main", "monthly")
  /// Notes
  static let notes = L10n.tr("Main", "notes")
  /// Reset Justins Tips
  static let resetTips = L10n.tr("Main", "reset_tips")
  /// Reset Streak
  static let resetStreak = L10n.tr("Main", "resetStreak")
  /// Save
  static let save = L10n.tr("Main", "save")
  /// Search
  static let search = L10n.tr("Main", "search")
  /// Tags
  static let tags = L10n.tr("Main", "tags")
  /// Title
  static let title = L10n.tr("Main", "title")
  /// Weekly
  static let weekly = L10n.tr("Main", "weekly")
  /// Yearly
  static let yearly = L10n.tr("Main", "yearly")

  enum Stats {
    /// 0 Points to Allocate
    static let noPointsToAllocate = L10n.tr("Main", "stats.no_points_to_allocate")
    /// 1 Point to Allocate
    static let onePointToAllocate = L10n.tr("Main", "stats.one_point_to_allocate")
    /// %d Point to Allocate
    static func pointsToAllocate(_ p1: Int) -> String {
      return L10n.tr("Main", "stats.points_to_allocate", p1)
    }
  }

  enum Tasks {
    /// Daily
    static let daily = L10n.tr("Main", "tasks.daily")
    /// Habit
    static let habit = L10n.tr("Main", "tasks.habit")
    /// Reward
    static let reward = L10n.tr("Main", "tasks.reward")
    /// To-Do
    static let todo = L10n.tr("Main", "tasks.todo")

    enum Form {
      /// Checklist
      static let checklist = L10n.tr("Main", "tasks.form.checklist")
      /// Controls
      static let controls = L10n.tr("Main", "tasks.form.controls")
      /// New %@
      static func create(_ p1: String) -> String {
        return L10n.tr("Main", "tasks.form.create", p1)
      }
      /// What do you want to do regularly?
      static let dailiesTitlePlaceholder = L10n.tr("Main", "tasks.form.dailies_title_placeholder")
      /// Day of the month
      static let dayOfMonth = L10n.tr("Main", "tasks.form.day_of_month")
      /// Day of the week
      static let dayOfWeek = L10n.tr("Main", "tasks.form.day_of_week")
      /// Difficulty
      static let difficulty = L10n.tr("Main", "tasks.form.difficulty")
      /// Due date
      static let dueDate = L10n.tr("Main", "tasks.form.due_date")
      /// Edit %@
      static func edit(_ p1: String) -> String {
        return L10n.tr("Main", "tasks.form.edit", p1)
      }
      /// Every
      static let every = L10n.tr("Main", "tasks.form.every")
      /// What habits do you want to foster or break?
      static let habitTitlePlaceholder = L10n.tr("Main", "tasks.form.habit_title_placeholder")
      /// New checklist item
      static let newChecklistItem = L10n.tr("Main", "tasks.form.new_checklist_item")
      /// New reminder
      static let newReminder = L10n.tr("Main", "tasks.form.new_reminder")
      /// Include any notes to help you out
      static let notesPlaceholder = L10n.tr("Main", "tasks.form.notes_placeholder")
      /// Remind me
      static let remindMe = L10n.tr("Main", "tasks.form.remind_me")
      /// Reminders
      static let reminders = L10n.tr("Main", "tasks.form.reminders")
      /// Repeats
      static let repeats = L10n.tr("Main", "tasks.form.repeats")
      /// Reset Streak
      static let resetStreak = L10n.tr("Main", "tasks.form.reset_streak")
      /// How do you want to reward yourself?
      static let rewardsTitlePlaceholder = L10n.tr("Main", "tasks.form.rewards_title_placeholder")
      /// Scheduling
      static let scheduling = L10n.tr("Main", "tasks.form.scheduling")
      /// Start date
      static let startDate = L10n.tr("Main", "tasks.form.start_date")
      /// Tags
      static let tags = L10n.tr("Main", "tasks.form.tags")
      /// What do you want to complete once?
      static let todosTitlePlaceholder = L10n.tr("Main", "tasks.form.todos_title_placeholder")
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
