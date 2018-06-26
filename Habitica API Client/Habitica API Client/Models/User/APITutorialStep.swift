//
//  APITutorialStep.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 30.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APITutorialStep: TutorialStepProtocol {
    var key: String?
    var type: String?
    var wasSeen: Bool
    
    init(type: String?, key: String?, wasSeen: Bool) {
        self.key = key
        self.type = type
        self.wasSeen = wasSeen
    }
}
