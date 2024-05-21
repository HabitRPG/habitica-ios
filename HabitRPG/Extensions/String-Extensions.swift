//
//  String-Extensions.swift
//  Habitica
//
//  Created by Phillip on 18.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

extension String {
    
    // https://gist.github.com/zhjuncai/6af27ca9649126dd326c
    func widthWithConstrainedHeight(_ height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.width
    }
    
    public static func forTaskQuality(task: TaskProtocol) -> String {
        let taskValue = task.value
        if taskValue < -20 {
            return L10n.Tasks.Quality.worst
        } else if taskValue < -10 {
            return L10n.Tasks.Quality.worse
        } else if taskValue < -1 {
            return L10n.Tasks.Quality.bad
        } else if taskValue < 1 {
            return L10n.Tasks.Quality.neutral
        } else if taskValue < 5 {
            return L10n.Tasks.Quality.good
        } else if taskValue < 10 {
            return L10n.Tasks.Quality.better
        } else {
            return L10n.Tasks.Quality.best
        }
    }
}

extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
                                             options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}

// swiftlint:disable all

//
//  String+Emoji.swift
//  emoji-swift
//
//  Created by Safx Developer on 2015/04/07.
//  Copyright (c) 2015 Safx Developers. All rights reserved.
//

extension String {

    fileprivate static var emojiUnescapeRegExp = createEmojiUnescapeRegExp()
    fileprivate static var emojiEscapeRegExp   = createEmojiEscapeRegExp()
    fileprivate static var indexedShortnames   = indexShortnames()
    fileprivate static var indexedCodepoints   = indexCodepoints()

    fileprivate static func createEmojiUnescapeRegExp() -> NSRegularExpression? {
        let v = Emoji.allCases.flatMap { $0.shortnames }
            .map { ":\(NSRegularExpression.escapedPattern(for: $0)):" }
        do {
            let regex = try NSRegularExpression(pattern: v.joined(separator: "|"), options: [])
            return regex
        } catch {
            print(error)
        }
        return nil
    }

    fileprivate static func createEmojiEscapeRegExp() -> NSRegularExpression? {
        let v = Emoji.allCases.flatMap { $0.codepoints }
            .map { NSRegularExpression.escapedPattern(for: $0) }
            .sorted()
            .reversed()
        do {
            let regex = try NSRegularExpression(pattern: v.joined(separator: "|"), options: [])
            return regex
        } catch {
            print(error)
        }
        return nil
    }
    
    fileprivate static func indexShortnames() -> [String: Int] {
        let emojis = Emoji.allCases
        return emojis.reduce([String: Int](), { dict, emoji -> [String: Int] in
            guard let index = emojis.firstIndex(of: emoji) else { return [:] }
            return emoji.shortnames.reduce(dict, { eDict, shortname -> [String: Int] in
                var finalDict = eDict
                finalDict[shortname] = index
                return finalDict
            })
        })
    }
    
    fileprivate static func indexCodepoints() -> [String: Int] {
        let emojis = Emoji.allCases
        return emojis.reduce([String: Int](), { dict, emoji -> [String: Int] in
            guard let index = emojis.firstIndex(of: emoji) else { return [:] }
            return emoji.codepoints.reduce(dict, { eDict, codepoint -> [String: Int] in
                var finalDict = eDict
                finalDict[codepoint] = index
                return finalDict
            })
        })
    }
    
    public var unicodeEmoji: String {
        var s = self as NSString
        let ms = String.emojiUnescapeRegExp?.matches(in: self, options: [], range: NSMakeRange(0, s.length))
        ms?.reversed().forEach { m in
            let r = m.range
            let p = s.substring(with: r)
            let px = p[p.index(after: p.startIndex) ..< p.index(before: p.endIndex)]
            let index = String.indexedShortnames[String(px)]
            if let i = index {
                let e = Emoji.allCases[i]
                s = s.replacingCharacters(in: r, with: e.codepoints.first!) as NSString
            }
        }
        return s as String
    }

    public var cheatCodeEmoji: String {
        var s = self as NSString
        let ms = String.emojiEscapeRegExp?.matches(in: self, options: [], range: NSMakeRange(0, s.length))
        ms?.reversed().forEach { m in
            let r = m.range
            let p = s.substring(with: r)
            let index = String.indexedCodepoints[p]
            if let i = index {
                let e = Emoji.allCases[i]
                s = s.replacingCharacters(in: r, with: ":\(e.shortnames.first!):") as NSString
            }
        }
        return s as String
    }
    
    public var translatedClassName: String {
        switch self {
        case "healer":
            return L10n.Classes.healer
        case "wizard":
            return L10n.Classes.mage
        case "mage":
            return L10n.Classes.mage
        case "rogue":
            return L10n.Classes.rogue
        default:
            return L10n.Classes.warrior
        }
    }
    
    public var translatedClassNamePlural: String {
        switch self {
        case "healer":
            return L10n.Classes.healers
        case "wizard":
            return L10n.Classes.mages
        case "mage":
            return L10n.Classes.mages
        case "rogue":
            return L10n.Classes.rogues
        default:
            return L10n.Classes.warriors
        }
    }

}

// swiftlint:enable all
