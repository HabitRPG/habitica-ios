// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
enum L10n {
  /// Controls
  static let controls = L10n.tr("Main", "controls")
  /// Difficulty
  static let difficulty = L10n.tr("Main", "difficulty")
  /// Notes
  static let notes = L10n.tr("Main", "notes")
  /// Reset Justins Tips
  static let resetTips = L10n.tr("Main", "reset_tips")
  /// Reset Streak
  static let resetStreak = L10n.tr("Main", "resetStreak")
  /// Search
  static let search = L10n.tr("Main", "search")
  /// Tags
  static let tags = L10n.tr("Main", "tags")
  /// Title
  static let title = L10n.tr("Main", "title")

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
    /// Create %@
    static func create(_ p1: String) -> String {
      return L10n.tr("Main", "tasks.create", p1)
    }
    /// Daily
    static let daily = L10n.tr("Main", "tasks.daily")
    /// Edit %@
    static func edit(_ p1: String) -> String {
      return L10n.tr("Main", "tasks.edit", p1)
    }
    /// Habit
    static let habit = L10n.tr("Main", "tasks.habit")
    /// Reward
    static let reward = L10n.tr("Main", "tasks.reward")
    /// To-Do
    static let todo = L10n.tr("Main", "tasks.todo")
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
