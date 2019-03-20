//
//  APIQuestColors.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 22.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIQuestColors: QuestColorsProtocol, Decodable {
    var dark: String?
    var medium: String?
    var light: String?
    var extralight: String?
    
}
