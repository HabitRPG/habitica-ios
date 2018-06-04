//
//  ArmoireResponseProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 04.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol ArmoireResponseProtocol {
    var type: String? { get set }
    var dropKey: String? { get set }
    var dropArticle: String? { get set }
    var dropText: String? { get set }
    var value: Float? { get set }
}
