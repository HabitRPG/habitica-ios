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

    func name() -> String {
        // swiftlint:disable switch_case_on_newline
        switch self {
        case .supportEmail: return "supportEmail"
        case .shopSpriteSuffix: return "shopSpriteSuffix"
        case .maxChatLength: return "maxChatLength"
        case .enableGiftOneGetOne: return "enableGiftOneGetOne"
        case .enableUsernameAutocomplete: return "enableUsernameAutocomplete"
        case .spriteSubstitutions: return "spriteSubstitution"
        case .stableName: return "stableName"
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
            return NSString(string: """
{
  \"pets\": {
    \"Wolf-Veteran\": \"PandaCub-Veggie\",
    \"Wolf-Cerberus\": \"PandaCub-Veggie\",
    \"Dragon-Hydra\": \"PandaCub-Veggie\",
    \"Turkey-\": \"PandaCub-Veggie\",
    \"BearCub-Polar\": \"PandaCub-Veggie\",
    \"MantisShrimp-\": \"PandaCub-Veggie\",
    \"JackOLantern-\": \"PandaCub-Veggie\",
    \"Mammoth-\": \"PandaCub-Veggie\",
    \"Tiger-Veteran\": \"PandaCub-Veggie\",
    \"Phoenix-\": \"PandaCub-Veggie\",
    \"Turkey-Gilded\": \"PandaCub-Veggie\",
    \"MagicalBee-\": \"PandaCub-Veggie\",
    \"Lion-Veteran\": \"PandaCub-Veggie\",
    \"Gryphon-RoyalPurple\": \"PandaCub-Veggie\",
    \"JackOLantern-Ghost\": \"PandaCub-Veggie\",
    \"Jackalope-RoyalPurple\": \"PandaCub-Veggie\",
    \"Orca-\": \"PandaCub-Veggie\",
    \"Bear-Veteran\": \"PandaCub-Veggie\",
    \"Hippogriff-Hopeful\": \"PandaCub-Veggie\",
    \"Fox-Veteran\": \"PandaCub-Veggie\",
    \"JackOLantern-Glow\": \"PandaCub-Veggie\",
    \"Wolf-\": \"Wolf-Veggie\",
    \"TigerCub-\": \"TigerCub-Veggie\",
    \"PandaCub-\": \"PandaCub-Veggie\",
    \"LionCub-\": \"LionCub-Veggie\",
    \"Fox-\": \"Fox-Veggie\",
    \"FlyingPig-\": \"FlyingPig-Veggie\",
    \"Dragon-\": \"Dragon-Veggie\",
    \"Cactus-\": \"Cactus-Veggie\",
    \"BearCub-\": \"BearCub-Veggie\",
    \"Gryphon-\": \"Fox-Veggie\",
    \"Hedgehog-\": \"Fox-Veggie\",
    \"Deer-\": \"Fox-Veggie\",
    \"Egg-\": \"Fox-Veggie\",
    \"Rat-\": \"Fox-Veggie\",
    \"Octopus-\": \"Fox-Veggie\",
    \"Seahorse-\": \"Fox-Veggie\",
    \"Parrot-\": \"Fox-Veggie\",
    \"Rooster-\": \"Fox-Veggie\",
    \"Spider-\": \"Fox-Veggie\",
    \"Owl-\": \"Fox-Veggie\",
    \"Penguin-\": \"Fox-Veggie\",
    \"TRex-\": \"Fox-Veggie\",
    \"Rock-\": \"Fox-Veggie\",
    \"Bunny-\": \"Fox-Veggie\",
    \"Slime-\": \"Fox-Veggie\",
    \"Sheep-\": \"Fox-Veggie\",
    \"Cuttlefish-\": \"Fox-Veggie\",
    \"Whale-\": \"Fox-Veggie\",
    \"Cheetah-\": \"Fox-Veggie\",
    \"Horse-\": \"Fox-Veggie\",
    \"Frog-\": \"Fox-Veggie\",
    \"Snake-\": \"Fox-Veggie\",
    \"Unicorn-\": \"Fox-Veggie\",
    \"Sabretooth-\": \"Fox-Veggie\",
    \"Monkey-\": \"Fox-Veggie\",
    \"Snail-\": \"Fox-Veggie\",
    \"Falcon-\": \"Fox-Veggie\",
    \"Treeling-\": \"Fox-Veggie\",
    \"Axolotl-\": \"Fox-Veggie\",
    \"Turtle-\": \"Fox-Veggie\",
    \"Armadillo-\": \"Fox-Veggie\",
    \"Cow-\": \"Fox-Veggie\",
    \"Beetle-\": \"Fox-Veggie\",
    \"Ferret-\": \"Fox-Veggie\",
    \"Sloth-\": \"Fox-Veggie\",
    \"Triceratops-\": \"Fox-Veggie\",
    \"GuineaPig-\": \"Fox-Veggie\",
    \"Peacock-\": \"Fox-Veggie\",
    \"Butterfly-\": \"Fox-Veggie\",
    \"Nudibranch-\": \"Fox-Veggie\",
    \"Hippo-\": \"Fox-Veggie\",
    \"Yarn-\": \"Fox-Veggie\",
    \"Pterodactyl-\": \"Fox-Veggie\",
    \"Badger-\": \"Fox-Veggie\",
    \"Squirrel-\": \"Fox-Veggie\",
    \"SeaSerpent-\": \"Fox-Veggie\",
    \"Kangaroo-\": \"Fox-Veggie\",
    \"Alligator-\": \"Fox-Veggie\",
    \"Velociraptor-\": \"Fox-Veggie\",
  }
}
""")
        case .stableName:
            return NSString(string: "")
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
            .stableName
        ]
    }
}

@objc
class ConfigRepository: NSObject {

    private static let remoteConfig = RemoteConfig.remoteConfig()
    private let userConfig = UserDefaults.standard

    @objc
    func fetchremoteConfig() {
        ConfigRepository.remoteConfig.fetch(withExpirationDuration: HabiticaAppDelegate.isRunningLive() ? 3600 : 0) { (first, second) in
            ConfigRepository.remoteConfig.activateFetched()
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
