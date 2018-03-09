//
//  RealmProfile.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

@objc
class RealmProfile: Object, ProfileProtocol {
    @objc dynamic var name: String?
    @objc dynamic var blurb: String?
    
    convenience init(_ profile: ProfileProtocol) {
        self.init()
        name = profile.name
        blurb = profile.blurb
    }
}
