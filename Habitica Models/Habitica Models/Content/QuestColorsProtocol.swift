//
//  QuestColorsProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 22.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol QuestColorsProtocol {
    var dark: String? { get set }
    var medium: String? { get set }
    var light: String? { get set }
    var extralight: String? { get set }

}
