//
//  AnimalProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol AnimalProtocol: BaseModelProtocol {
    var key: String? { get set }
    var egg: String? { get set }
    var potion: String? { get set }
    var type: String? { get set }
    var text: String? { get set }
}
