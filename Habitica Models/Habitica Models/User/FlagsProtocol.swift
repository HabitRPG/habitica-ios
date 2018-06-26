//
// Created by Phillip Thelen on 09.03.18.
// Copyright (c) 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol FlagsProtocol {
    var armoireEmpty: Bool { get set }
    var cronCount: Int { get set }
    var rebirthEnabled: Bool { get set }
    var communityGuidelinesAccepted: Bool { get set }
    var hasNewStuff: Bool { get set }
    var armoireOpened: Bool { get set }
    var chatRevoked: Bool { get set }
    var classSelected: Bool { get set }
    var itemsEnabled: Bool { get set }
    var tutorials: [TutorialStepProtocol] { get set }
}
