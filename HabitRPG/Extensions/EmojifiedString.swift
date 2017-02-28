import Foundation
import NSString_Emoji

extension String {
    var unicodeEmoji: String {
        return (self as NSString).replacingEmojiCheatCodesWithUnicode()
    }
    
    var cheatCodeEmoji: String {
        return (self as NSString).replacingEmojiUnicodeWithCheatCodes()

    }
}
