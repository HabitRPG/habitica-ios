//
//  GetUserCall.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/30/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import FunkyNetwork
import Eson
import ReactiveSwift
import Result

class GetUserCall: AuthenticatedCall {
    public lazy var userSignal: Signal<HRPGUser?, NoError> = jsonSignal.map(GetUserCall.parse)
    
    public init(configuration: ServerConfigurationProtocol = HRPGServerConfig.current, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        super.init(configuration: configuration, httpMethod: "GET", endpoint: "user", postData: nil, stubHolder: stubHolder)
    }
    
    static func parse(_ json: Any) -> HRPGUser? {
        if let json: [String: AnyObject] = json as? [String: AnyObject] {
            return Eson().fromJsonDictionary(json, clazz: HRPGUser.self)
        }
        return nil
    }
}
