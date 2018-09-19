//
//  RemoteConfigRepository.swift
//  Habitica
//
//  Created by Phillip Thelen on 16/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//
import Foundation
import Habitica_API_Client

@objc
enum ConfigVariable: Int {
    case enableRepeatables, supportEmail, enableNewShops, shopSpriteSuffix, maxChatLength, enableChangeUsername

    func name() -> String {
        // swiftlint:disable switch_case_on_newline
        switch self {
        case .enableRepeatables: return "enableRepeatables"
        case .supportEmail: return "supportEmail"
        case .enableNewShops: return "enableNewShops"
        case .shopSpriteSuffix: return "shopSpriteSuffix"
        case .maxChatLength: return "maxChatLength"
        case .enableChangeUsername: return "enableChangeUsername"
        }
        // swiftlint:enable switch_case_on_newline
    }
}

@objc
class ConfigRepository: NSObject {

    private static let configUrl = "https://s3.amazonaws.com/habitica-assets/mobileApp/endpoint/config-ios.json"
    private static let configVariables: [ConfigVariable] = [.enableRepeatables, .supportEmail, .enableNewShops, .shopSpriteSuffix, .maxChatLength, .enableChangeUsername]
    private let userConfig = UserDefaults.standard

    @objc
    func fetchremoteConfig() {
        let call = RetrieveRemoteConfigCall()
        call.fire()
        call.jsonSignal.observeValues { jsonObject in
            if let jsonDict = jsonObject as? [String: Any] {
                for variable in ConfigRepository.configVariables {
                    if jsonDict.contains(where: { (key, _) -> Bool in
                        return key == variable.name()
                    }) {
                        self.userConfig.set(jsonDict[variable.name()], forKey: variable.name())
                    }
                }
            }
        }
    }

    @objc
    func bool(variable: ConfigVariable) -> Bool {
        return userConfig.bool(forKey: variable.name())
    }

    @objc
    func string(variable: ConfigVariable) -> String? {
        return userConfig.string(forKey: variable.name())
    }
    @objc
    func string(variable: ConfigVariable, defaultValue: String) -> String {
        return userConfig.string(forKey: variable.name()) ?? defaultValue
    }
    
    @objc
    func integer(variable: ConfigVariable) -> Int {
        return userConfig.integer(forKey: variable.name())
    }
}
