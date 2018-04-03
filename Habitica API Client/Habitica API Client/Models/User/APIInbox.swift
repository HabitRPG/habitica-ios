//
//  APIInbox.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 03.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIInbox: InboxProtocol, Decodable {
    @objc dynamic var optOut: Bool = false
}
