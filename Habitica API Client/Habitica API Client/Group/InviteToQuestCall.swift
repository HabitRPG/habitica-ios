//
//  InviteToQuestCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class InviteToQuestCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(groupID: String, quest: QuestProtocol, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "group.json")) {
        super.init(httpMethod: .POST, endpoint: "groups/\(groupID)/quests/invite/\(quest.key ?? "")", postData: nil, stubHolder: stubHolder)
    }
}
