//
//  ChallengeCategory.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 24.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol ChallengeCategoryProtocol {
    var id: String? { get set }
    var slug: String? { get set }
    var name: String? { get set }
}
