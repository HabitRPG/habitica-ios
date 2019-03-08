//
//  PushDeviceProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 28.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol PushDeviceProtocol {
    var type: String? { get set }
    var regId: String? { get set }
}
