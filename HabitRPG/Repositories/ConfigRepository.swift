//
//  RemoteConfigRepository.swift
//  Habitica
//
//  Created by Phillip Thelen on 16/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import Alamofire

@objc
enum ConfigVariable: Int {
    case enableRepeatables, supportEmail, enableNewShops, shopSpriteSuffix

    func name() -> String {
        // swiftlint:disable switch_case_on_newline
        switch self {
        case .enableRepeatables: return "enableRepeatables"
        case .supportEmail: return "supportEmail"
        case .enableNewShops: return "enableNewShops"
        case .shopSpriteSuffix: return "shopSpriteSuffix"
        }
        // swiftlint:enable switch_case_on_newline
    }
}

@objc
class ConfigRepository: NSObject {

    private static let configUrl = "https://s3.amazonaws.com/habitica-assets/mobileApp/endpoint/config-ios.json"
    private static let configVariables: [ConfigVariable] = [.enableRepeatables, .supportEmail, .enableNewShops, .shopSpriteSuffix]
    private let userConfig = UserDefaults.standard

    func fetchremoteConfig() {
        Alamofire.request(ConfigRepository.configUrl).responseJSON { response in
            if let JSON = response.result.value as? [String: Any] {
                for variable in ConfigRepository.configVariables {
                    if JSON.contains(where: { (key, _) -> Bool in
                        return key == variable.name()
                    }) {
                        self.userConfig.set(JSON[variable.name()], forKey: variable.name())
                    }
                }
            }
        }
    }

    func bool(variable: ConfigVariable) -> Bool {
        return userConfig.bool(forKey: variable.name())
    }

    func string(variable: ConfigVariable) -> String? {
        return userConfig.string(forKey: variable.name())
    }
    func string(variable: ConfigVariable, defaultValue: String) -> String {
        return userConfig.string(forKey: variable.name()) ?? defaultValue
    }
    
    func integer(variable: ConfigVariable) -> Int {
        return userConfig.integer(forKey: variable.name())
    }
}
