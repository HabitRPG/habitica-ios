//
//  StringExtensionsTests.swift
//  HabiticaTests
//

import XCTest
@testable import Habitica
import Habitica_Models

class StringExtensionsTests: XCTestCase {

    // MARK: isValidEmail

    func testValidEmails() {
        for email in ["a@b.co", "first.last@example.com", "x+tag@example.org", "UPPER@EXAMPLE.COM", "a_b-c@d-e.io"] {
            XCTAssertTrue(email.isValidEmail(), email)
        }
    }

    func testEmailsWithSubdomainsAreValid() {
        // regression: the domain part only allowed a single dot, rejecting these
        for email in ["name@domain.co.uk", "x@mail.example.com", "student@cs.uni.example.edu"] {
            XCTAssertTrue(email.isValidEmail(), email)
        }
    }

    func testInvalidEmails() {
        for email in ["", "plain", "a@b", "@example.com", "a@", "a@@b.com", "a b@c.com",
                      "a@b..com", "a@.b.com", "a@-b.com", "a@b-.com", "a@b.com.", " a@b.com", "a@b.com ", "é@b.com"] {
            XCTAssertFalse(email.isValidEmail(), email.debugDescription)
        }
    }

    func testTrailingNewlineIsInvalid() {
        // `$` would match before a final newline, letting pasted text through
        XCTAssertFalse("a@b.com\n".isValidEmail())
    }

    func testEmailWithMultiByteCharactersDoesNotCrash() {
        XCTAssertFalse("a@b.com😀".isValidEmail())
        XCTAssertFalse("😀a@b.com".isValidEmail())
    }

    // MARK: stringWithAbbreviatedNumber

    private var decimalSeparator: String { Locale.current.decimalSeparator ?? "." }

    func testSmallNumbersAreNotAbbreviated() {
        XCTAssertEqual("0".stringWithAbbreviatedNumber(), "0")
        XCTAssertEqual("12".stringWithAbbreviatedNumber(), "12")
        XCTAssertEqual("999".stringWithAbbreviatedNumber(), "999")
    }

    func testAbbreviationSuffixes() {
        XCTAssertEqual("1000".stringWithAbbreviatedNumber(), "1k")
        XCTAssertEqual("2000000".stringWithAbbreviatedNumber(), "2m")
        XCTAssertEqual("3000000000".stringWithAbbreviatedNumber(), "3b")
        XCTAssertEqual("4000000000000".stringWithAbbreviatedNumber(), "4t")
        XCTAssertEqual("1500".stringWithAbbreviatedNumber(), "1\(decimalSeparator)5k")
    }

    func testFractionDigitsAreRespected() {
        XCTAssertEqual("1234".stringWithAbbreviatedNumber(maximumFractionDigits: 0), "1k")
        XCTAssertEqual("1234".stringWithAbbreviatedNumber(maximumFractionDigits: 1), "1\(decimalSeparator)2k")
        XCTAssertEqual("12.346".stringWithAbbreviatedNumber(), "12\(decimalSeparator)35")
    }

    func testRoundingUpMovesToNextSuffix() {
        // regression: used to render "1,000k"
        XCTAssertEqual("999999".stringWithAbbreviatedNumber(), "1m")
        XCTAssertEqual("999995".stringWithAbbreviatedNumber(), "1m")
        XCTAssertEqual("999500".stringWithAbbreviatedNumber(maximumFractionDigits: 0), "1m")
        XCTAssertEqual("999994".stringWithAbbreviatedNumber(), "999\(decimalSeparator)99k")
    }

    func testInvalidInputReturnsEmptyString() {
        XCTAssertEqual("".stringWithAbbreviatedNumber(), "")
        XCTAssertEqual("abc".stringWithAbbreviatedNumber(), "")
        XCTAssertEqual("1k".stringWithAbbreviatedNumber(), "")
    }

    func testNonFiniteInputDoesNotHang() {
        // regression: "inf" looped forever since inf / 1000 stays inf
        XCTAssertEqual("inf".stringWithAbbreviatedNumber(), "")
        XCTAssertEqual(String(Float.infinity).stringWithAbbreviatedNumber(), "")
        XCTAssertEqual("nan".stringWithAbbreviatedNumber(), "")
    }

    func testHugeNumbersBeyondLookupKeepNumber() {
        // 1e27 is past the last suffix ("s" = 1e24), so the number is shown without one
        XCTAssertEqual("1e24".stringWithAbbreviatedNumber(), "1s")
        XCTAssertEqual("1e27".stringWithAbbreviatedNumber(), "1")
    }

    // MARK: stripHTML

    func testStripHTML() {
        XCTAssertEqual("<b>bold</b> and <i class=\"x\">italic</i>".stripHTML(), "bold and italic")
        XCTAssertEqual("no tags".stripHTML(), "no tags")
        XCTAssertEqual("".stripHTML(), "")
        XCTAssertEqual("a<br/>b".stripHTML(), "ab")
        // known limitation: text between stray brackets is treated as a tag
        XCTAssertEqual("I <3 cats > dogs".stripHTML(), "I  dogs")
    }

    // MARK: Emoji

    func testShortnameToUnicode() {
        let smile = Emoji.smile.codepoints.first!
        XCTAssertEqual(":smile:".unicodeEmoji, smile)
        XCTAssertEqual("hi :smile: there :smile:".unicodeEmoji, "hi \(smile) there \(smile)")
    }

    func testSimilarShortnamesDoNotCollide() {
        XCTAssertEqual(":sweat_smile:".unicodeEmoji, Emoji.sweat_smile.codepoints.first!)
    }

    func testUnknownShortnamesAreKept() {
        XCTAssertEqual(":not_an_emoji:".unicodeEmoji, ":not_an_emoji:")
        XCTAssertEqual("smile".unicodeEmoji, "smile")
        XCTAssertEqual("".unicodeEmoji, "")
    }

    func testEmojiRoundTrip() {
        let text = "Done :smile: :sweat_smile:"
        XCTAssertEqual(text.unicodeEmoji.cheatCodeEmoji, text)
    }

    func testCheatCodeKeepsPlainText() {
        XCTAssertEqual("plain text".cheatCodeEmoji, "plain text")
    }

    // MARK: Class names

    func testTranslatedClassName() {
        XCTAssertEqual("healer".translatedClassName, L10n.Classes.healer)
        XCTAssertEqual("wizard".translatedClassName, L10n.Classes.mage)
        XCTAssertEqual("mage".translatedClassName, L10n.Classes.mage)
        XCTAssertEqual("rogue".translatedClassName, L10n.Classes.rogue)
        XCTAssertEqual("warrior".translatedClassName, L10n.Classes.warrior)
        // unknown values fall back to warrior, the server default
        XCTAssertEqual("".translatedClassName, L10n.Classes.warrior)
        XCTAssertEqual("Healer".translatedClassName, L10n.Classes.warrior)
    }

    func testTranslatedClassNamePlural() {
        XCTAssertEqual("healer".translatedClassNamePlural, L10n.Classes.healers)
        XCTAssertEqual("wizard".translatedClassNamePlural, L10n.Classes.mages)
        XCTAssertEqual("rogue".translatedClassNamePlural, L10n.Classes.rogues)
        XCTAssertEqual("anything".translatedClassNamePlural, L10n.Classes.warriors)
    }

    func testHabiticaClassMatchesStringTranslation() {
        for habiticaClass in [HabiticaClass.warrior, .mage, .healer, .rogue] {
            XCTAssertEqual(habiticaClass.translatedName, habiticaClass.rawValue.translatedClassName)
        }
    }

    // MARK: Task quality

    func testTaskQualityBoundaries() {
        let expectations: [(Float, String)] = [
            (-100, L10n.Tasks.Quality.worst),
            (-20.01, L10n.Tasks.Quality.worst),
            (-20, L10n.Tasks.Quality.worse),
            (-10.01, L10n.Tasks.Quality.worse),
            (-10, L10n.Tasks.Quality.bad),
            (-1.01, L10n.Tasks.Quality.bad),
            (-1, L10n.Tasks.Quality.neutral),
            (0, L10n.Tasks.Quality.neutral),
            (0.99, L10n.Tasks.Quality.neutral),
            (1, L10n.Tasks.Quality.good),
            (4.99, L10n.Tasks.Quality.good),
            (5, L10n.Tasks.Quality.better),
            (9.99, L10n.Tasks.Quality.better),
            (10, L10n.Tasks.Quality.best),
            (1000, L10n.Tasks.Quality.best)
        ]
        let task = TestTask()
        for (value, expected) in expectations {
            task.value = value
            XCTAssertEqual(String.forTaskQuality(task: task), expected, "value \(value)")
        }
    }

    // MARK: NSRange

    func testRangeSafety() {
        let string = "hello" as NSString
        XCTAssertTrue(NSRange(location: 0, length: 5).isSafe(for: string))
        XCTAssertTrue(NSRange(location: 5, length: 0).isSafe(for: string))
        XCTAssertFalse(NSRange(location: 0, length: 6).isSafe(for: string))
        XCTAssertFalse(NSRange(location: 3, length: 3).isSafe(for: string))
        XCTAssertFalse(NSRange(location: NSNotFound, length: 0).isSafe(for: string))
        XCTAssertTrue(NSRange(location: 0, length: 0).isSafe(for: "" as NSString))
        // ranges are UTF-16 based: one emoji is two units
        XCTAssertTrue(NSRange(location: 0, length: 2).isSafe(for: "😀" as NSString))
        XCTAssertTrue(NSRange(location: 0, length: 2).isSafe(for: NSAttributedString(string: "😀")))
        XCTAssertFalse(NSRange(location: 1, length: 2).isSafe(for: NSAttributedString(string: "😀")))
    }

    // MARK: Challenge categories

    func testChallengeCategoryLookup() {
        XCTAssertEqual(ChallengeCategory.localizedCategoryNameFor(name: "habitica_official"), L10n.ChallengeCategory.habiticaOfficial)
        XCTAssertEqual(ChallengeCategory.localizedCategoryNameFor(name: "time_management"), L10n.ChallengeCategory.timeManagement)
        XCTAssertNil(ChallengeCategory.localizedCategoryNameFor(name: "unknown"))
        XCTAssertNil(ChallengeCategory.localizedCategoryNameFor(name: ""))
        XCTAssertNil(ChallengeCategory.localizedCategoryNameFor(name: "Academics"))
    }

    func testEveryChallengeCategoryHasDistinctName() {
        let names = ChallengeCategory.allCases.map(\.localizedName)
        XCTAssertFalse(names.contains(where: \.isEmpty))
        XCTAssertEqual(Set(names).count, names.count)
    }
}
