//
//  MemberProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 11.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol MemberProtocol: AvatarProtocol {
    var id: String? { get set }
    var profile: ProfileProtocol? { get set }
    var contributor: ContributorProtocol? { get set }
}

public extension MemberProtocol {
    var isModerator: Bool {
        return (contributor?.level ?? 0) >= 8
    }
}
