//
//  APIPushDevice.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 28.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIPushDevice: PushDeviceProtocol, Decodable {
    var updatedAt: Date?
    var createdAt: Date?
    var type: String?
    var regId: String?
}
