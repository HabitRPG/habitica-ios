//
//  RealmQuestColors.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 22.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmQuestColors: Object, QuestColorsProtocol {
    @objc dynamic var key: String?
    var dark: String?
    var medium: String?
    var light: String?
    var extralight: String?
    
    convenience init(key: String?, protocolObject: QuestColorsProtocol) {
        self.init()
        self.key = key
        dark = protocolObject.dark
        medium = protocolObject.medium
        light = protocolObject.light
        extralight = protocolObject.extralight
    }
}
