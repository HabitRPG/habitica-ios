//
//  LanguageHandler.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.03.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

enum AppLanguage: Int {
    case english
    case danish
    case spanish
    case czech
    case chinese
    case german
    case french
    case chineseSimplified
    case portugueseBrazil
    case hebrew
    case hungaruan
    case polish
    case russian
    case bulgarian
    case dutch
    case croatian
    case romanian
    case italian
    case japanese
    case ukrainian

    var name: String {
        switch self {
        case .english:
            return "English"
        case .danish:
            return "Dansk"
        case .spanish:
            return "Español"
        case .czech:
            return "čeština"
        case .chinese:
            return "中文（正體）"
        case .german:
            return "Deutsch"
        case .french:
            return "Français"
        case .chineseSimplified:
            return "中文（简体）"
        case .portugueseBrazil:
            return "Português Brasileiro"
        case .hebrew:
            return "עברית"
        case .polish:
            return "Polski"
        case .russian:
            return "Русский"
        case .bulgarian:
            return "Български"
        case .dutch:
            return "Nederlands"
        case .croatian:
            return "Hrvatski"
        case .romanian:
            return "român"
        case .italian:
            return "Italiano"
        case .japanese:
            return "日本語"
        case .hungaruan:
            return "Magyar"
        case .ukrainian:
            return "Українська"
        }
    }
    
    var code: String {
        switch self {
        case .english:
            return "en"
        case .danish:
            return "da"
        case .spanish:
            return "es"
        case .czech:
            return "cs"
        case .chinese:
            return "zh"
        case .german:
            return "de"
        case .french:
            return "fr"
        case .chineseSimplified:
            return "zh-Hans"
        case .portugueseBrazil:
            return "pt-BR"
        case .hebrew:
            return "he"
        case .polish:
            return "pl"
        case .russian:
            return "ru"
        case .bulgarian:
            return "bg"
        case .dutch:
            return "nl"
        case .croatian:
            return "hr"
        case .romanian:
            return "ro"
        case .italian:
            return "it"
        case .japanese:
            return "ja"
        case .hungaruan:
            return "hu"
        case .ukrainian:
            return "uk"
        }
    }
    
    var bundleCode: String {
        switch self {
        case .english:
            return "Base"
        default:
            return code
        }
    }
    
    static func allLanguages() -> [AppLanguage] {
        let languages: [AppLanguage] = [
            .english,
            .danish,
            .spanish,
            .czech,
            .german,
            .french,
            .chineseSimplified,
            .portugueseBrazil,
            .hebrew,
            .hungaruan,
            .polish,
            .russian,
            .bulgarian,
            .dutch,
            .croatian,
            .romanian,
            .italian,
            .japanese,
            .ukrainian
            ]
        return languages.sorted { $0.name < $1.name }
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("LanguageChangedNotification")
}

class LanguageHandler {
    
    static func getAppLanguage() -> AppLanguage {
        let languageCodes = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String]
        for code in languageCodes ?? [] {
            let locale = Locale(identifier: code)
            if let language = AppLanguage.allLanguages().first(where: { language -> Bool in
                return language.code == locale.language.languageCode?.identifier || language.code == code
            }) {
                return language
            }
        }
        return AppLanguage.english
    }
    
    static func setAppLanguage(_ language: AppLanguage) {
        let defaults = UserDefaults.standard
        var languages = defaults.array(forKey: "AppleLanguages") as? [String] ?? Locale.preferredLanguages
        languages.removeAll { $0 == language.code || $0.hasPrefix(language.code + "-") }
        languages.insert(language.code, at: 0)
        if !languages.contains(where: { $0 == "en" || $0.hasPrefix("en-") }) {
            languages.append("en")
        }
        defaults.set(languages, forKey: "AppleLanguages")
        defaults.synchronize()
        if let path = Bundle.main.path(forResource: language.bundleCode, ofType: "lproj") {
            L10n.bundle = Bundle(path: path)
        }
        NotificationCenter.default.post(name: .languageChanged, object: nil)
    }
}
