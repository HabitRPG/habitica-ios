//
//  PinResponseProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 17.07.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol PinResponseProtocol {
    var pinnedItems: [PinResponseItemProtocol] { get set }
    var unpinnedItems: [PinResponseItemProtocol] { get set }
}
