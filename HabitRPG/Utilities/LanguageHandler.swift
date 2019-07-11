//
//  LanguageHandler.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.03.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
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
    case polish
    case russian
    case bulgarian
    case dutch
    case croatian
    case romanian
    case italian
    case japanese
    
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
            return "中文（简体"
        case .german:
            return "Deutsch"
        case .french:
            return "Français"
        case .chineseSimplified:
            return "中文（正體)"
        case .portugueseBrazil:
            return "Português Brasileiro"
        case .hebrew:
            return "he"
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
            .chinese,
            .german,
            .french,
            .chineseSimplified,
            .portugueseBrazil,
            .hebrew,
            .polish,
            .russian,
            .bulgarian,
            .dutch,
            .croatian,
            .romanian,
            .italian,
            .japanese
            ]
        return languages.sorted { $0.name < $1.name }
    }
}

@objc
class LanguageHandler: NSObject {
    
    @objc
    static func getAppLanguage() -> AppLanguage {
        let languageCodes = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String]
        for code in languageCodes ?? [] {
            let locale = Locale(identifier: code)
            if let language = AppLanguage.allLanguages().first(where: { language -> Bool in
                return language.code == locale.languageCode
            }) {
                return language
            }
        }
        return AppLanguage.english
    }
    
    @objc
    static func setAppLanguage(_ language: AppLanguage) {
        let defaults = UserDefaults.standard
        defaults.set([language.code, "en"], forKey: "AppleLanguages")
        defaults.synchronize()
        if let path = Bundle.main.path(forResource: language.bundleCode, ofType: "lproj") {
            L10n.bundle = Bundle(path: path)
        }
    }
}
