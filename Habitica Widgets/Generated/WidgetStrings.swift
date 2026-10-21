// Generated using SwiftGen, by O.Halligon ??? https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable all

internal enum L10n {
  /// Update bundle if you need to change app language
  static var bundle: Bundle?

  /// Experience
  internal static var experience: String { return L10n.tr("WidgetStrings", "experience") }
  /// Health
  internal static var health: String { return L10n.tr("WidgetStrings", "health") }
  /// Level %d
  internal static func levelNumber(_ p1: Int) -> String {
    return L10n.tr("WidgetStrings", "level_number", p1)
  }
}

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    var format = NSLocalizedString(key, tableName: table, bundle: bundle ?? Bundle(for: BundleToken.self), comment: "")
    let value = String(format: format, locale: Locale.current, arguments: args)
    if value != key || Locale.current.identifier == "en" {
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

// swiftlint:enable all
