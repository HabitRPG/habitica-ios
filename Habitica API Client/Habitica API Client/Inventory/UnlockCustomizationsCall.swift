//
//  UnlockPathCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 24.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class UnlockCustomizationsCall: ResponseObjectCall<UserProtocol, APIUser> {
    public init(customizations: [CustomizationProtocol], stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        let path = customizations.map({ (customization) -> String in
            return customization.path
        }).joined(separator: ",")
        super.init(httpMethod: .POST, endpoint: "user/unlock/?path=\(path)", postData: nil, stubHolder: stubHolder)
    }
}
