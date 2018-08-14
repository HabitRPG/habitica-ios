//
//  InviteToGroupCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 20.07.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import FunkyNetwork
import ReactiveSwift

public class InviteToGroupCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(groupID: String, invitationType: String, inviter: String, members: [String], stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "group.json")) {
        var data: [String: Any] = [
            "inviter": inviter
        ]
        if invitationType == "uuids" {
            data[invitationType] = members
        } else {
            members.forEach { (email) in
            }
            data[invitationType] = members.map({ (email) -> [String:String] in
                return [
                    "email": email,
                    "name": email
                ]
            })
        }
        let json = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        super.init(httpMethod: .POST, endpoint: "groups/\(groupID)/invite", postData: json, stubHolder: stubHolder)
    }
}
