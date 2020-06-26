//
//  RemoteConfigRepository.swift
//  Habitica
//
//  Created by Phillip Thelen on 16/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//
import Foundation
import Habitica_API_Client
import FirebaseRemoteConfig

@objc
enum ConfigVariable: Int {
    case supportEmail
    case shopSpriteSuffix
    case maxChatLength
    case enableGiftOneGetOne
    case enableUsernameAutocomplete
    case spriteSubstitutions
    case stableName
    case lastVersionNumber
    case lastVersionCode
    case randomizeAvatar
    case enablePushMentions
    case showSubscriptionBanner
    case useNewMysteryBenefits
    case insufficientGemPurchase
    case insufficientGemPurchaseAdjust
    case raiseShops
    case feedbackURL
    case enableAdventureGuide

    func name() -> String {
        // swiftlint:disable switch_case_on_newline
        switch self {
        case .supportEmail: return "supportEmail"
        case .shopSpriteSuffix: return "shopSpriteSuffix"
        case .maxChatLength: return "maxChatLength"
        case .enableGiftOneGetOne: return "enableGiftOneGetOne"
        case .enableUsernameAutocomplete: return "enableUsernameAutocomplete"
        case .spriteSubstitutions: return "spriteSubstitutions"
        case .stableName: return "stableName"
        case .lastVersionNumber: return "lastVersionNumber"
        case .lastVersionCode: return "lastVersionCode"
        case .randomizeAvatar: return "randomizeAvatar"
        case .enablePushMentions: return "enablePushMentions"
        case .showSubscriptionBanner: return "showSubscriptionBanner"
        case .useNewMysteryBenefits: return "useNewMysteryBenefits"
        case .insufficientGemPurchase:return "insufficientGemPurchase"
        case .insufficientGemPurchaseAdjust: return "insufficientGemPurchaseAdjust"
        case .raiseShops: return "raiseShops"
        case .feedbackURL: return "feedbackURL"
        case .enableAdventureGuide: return "enableAdventureGuide"
        }
        // swiftlint:enable switch_case_on_newline
    }
    
    func defaultValue() -> NSObject {
        switch self {
        case .supportEmail:
            return NSString(string: "admin@habitica.com")
        case .shopSpriteSuffix:
            return NSString(string: "")
        case .maxChatLength:
            return NSNumber(integerLiteral: 3000)
        case .enableGiftOneGetOne:
            return NSNumber(booleanLiteral: false)
        case .enableUsernameAutocomplete:
            return NSNumber(booleanLiteral: false)
        case .spriteSubstitutions:
            return NSString(string: "{}")
        case .stableName:
            return NSString(string: "")
        case .lastVersionNumber:
            return NSString(string: "")
        case .lastVersionCode:
            return NSNumber(integerLiteral: 0)
        case .randomizeAvatar:
            return NSNumber(booleanLiteral: false)
        case .enablePushMentions:
            return NSNumber(booleanLiteral: false)
        case .showSubscriptionBanner:
            return NSNumber(booleanLiteral: false)
        case .useNewMysteryBenefits:
            return NSNumber(booleanLiteral: false)
        case .insufficientGemPurchase:
            return NSNumber(booleanLiteral: false)
        case .insufficientGemPurchaseAdjust:
            return NSNumber(booleanLiteral: false)
        case .raiseShops:
            return NSNumber(booleanLiteral: false)
        case .enableAdventureGuide:
            return NSNumber(booleanLiteral: false)
        case .feedbackURL:
            return NSString(string: "https://docs.google.com/forms/d/e/1FAIpQLScPhrwq_7P1C6PTrI3lbvTsvqGyTNnGzp1ugi1Ml0PFee_p5g/viewform?usp=sf_link")
        }
    }
    
    static func allVariables() -> [ConfigVariable] {
        return [
            .supportEmail,
            .shopSpriteSuffix,
            .maxChatLength,
            .enableGiftOneGetOne,
            .enableUsernameAutocomplete,
            .spriteSubstitutions,
            .stableName,
            .lastVersionNumber,
            .lastVersionCode,
            .randomizeAvatar,
            .enablePushMentions,
            .useNewMysteryBenefits,
            .insufficientGemPurchase,
            .insufficientGemPurchaseAdjust,
            .raiseShops,
            .feedbackURL,
            .enableAdventureGuide
        ]
    }
}

@objc
class ConfigRepository: NSObject {

    private static let remoteConfig = RemoteConfig.remoteConfig()
    private let userConfig = UserDefaults.standard

    @objc
    func fetchremoteConfig() {
        ConfigRepository.remoteConfig.fetch(withExpirationDuration: HabiticaAppDelegate.isRunningLive() ? 3600 : 0) { (_, _) in
            ConfigRepository.remoteConfig.activate(completionHandler: nil)
        }
        var defaults = [String: NSObject]()
        for variable in ConfigVariable.allVariables() {
            defaults[variable.name()] = variable.defaultValue()
        }
        ConfigRepository.remoteConfig.setDefaults(defaults)
    }

    @objc
    func bool(variable: ConfigVariable) -> Bool {
        return ConfigRepository.remoteConfig.configValue(forKey: variable.name()).boolValue
    }

    @objc
    func string(variable: ConfigVariable) -> String? {
        return ConfigRepository.remoteConfig.configValue(forKey: variable.name()).stringValue
    }
    
    @objc
    func string(variable: ConfigVariable, defaultValue: String) -> String {
        return ConfigRepository.remoteConfig.configValue(forKey: variable.name()).stringValue ?? defaultValue
    }
    
    @objc
    func integer(variable: ConfigVariable) -> Int {
        return ConfigRepository.remoteConfig.configValue(forKey: variable.name()).numberValue?.intValue ?? 0
    }
    
    @objc
    func dictionary(variable: ConfigVariable) -> NSDictionary {
        let configString = ConfigRepository.remoteConfig.configValue(forKey: variable.name()).stringValue
        if let data = configString?.data(using: String.Encoding.utf8) {
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let jsonDictionary = json as? NSDictionary {
                    return jsonDictionary
                }
            }
        }
        return NSDictionary()
    }
}
