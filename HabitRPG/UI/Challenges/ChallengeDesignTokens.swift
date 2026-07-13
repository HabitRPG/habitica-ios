import SwiftUI

enum ChallengeTheme {
    private static func hex(_ value: UInt) -> Color {
        Color(
            red: Double((value >> 16) & 0xFF) / 255.0,
            green: Double((value >> 8) & 0xFF) / 255.0,
            blue: Double(value & 0xFF) / 255.0
        )
    }

    private static func adaptive(light: UInt, dark: UInt) -> Color {
        hex(ThemeService.shared.theme.isDark ? dark : light)
    }

    static let habitFill = hex(0x24CC8E)
    static let habitGlyph = hex(0x0A5638)
    static let dailyFill = hex(0xFFBE5D)
    static let dailyGlyph = hex(0x7F4A00)
    static let dailyBlueFill = hex(0x4FA3DD)
    static let dailyBlueGlyph = hex(0x0B3D5C)
    static let todoFill = hex(0xFF944C)
    static let todoGlyph = hex(0x823200)
    static let disabledFill = hex(0xE6E5E9)
    static let disabledGlyph = hex(0xB5B3BB)
    static let completedBox = hex(0xD6D4DA)
    static let completedCheck = hex(0xFBFBFC)

    static let purple = hex(0x925CF3)
    static let deepPurple = hex(0x6133B4)
    static let deleteRed = hex(0xDE3F3F)
    static let joinGreen = hex(0x24CC8E)
    static let joinGreenText = hex(0x0A5638)
    static let leaveRed = hex(0xFE6165)
    static let leaveRedText = hex(0x5E1216)

    static let sectionLabel = hex(0x908D98)
    static var formSectionLabel: Color { adaptive(light: 0x6B6873, dark: 0x918E99) }
    static let username = hex(0x908D98)
    static let counter = hex(0xA4A1AB)
    static let completedText = hex(0xA8A5AE)
    static let cardFillLight = hex(0xF4F4F5)

    static var chipFill: Color { adaptive(light: 0xE1E0E3, dark: 0x4A474F) }
    static var chipText: Color { adaptive(light: 0x878190, dark: 0xC3C0C7) }
    static var joinedCount: Color { adaptive(light: 0x24A574, dark: 0x2ED49A) }
}
