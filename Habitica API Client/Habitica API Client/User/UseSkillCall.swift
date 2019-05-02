//
//  UseSkillCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 28.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class UseSkillCall: ResponseObjectCall<SkillResponseProtocol, APISkillResponse> {
    public init(skill: SkillProtocol, target: String? = nil, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        var url = "user/class/cast/\(skill.key ?? "")?targetType=\(skill.target ?? "")"
        if let targetId = target {
            url += "&targetId=\(targetId)"
        }
        super.init(httpMethod: .POST, endpoint: url, stubHolder: stubHolder)
    }
}
