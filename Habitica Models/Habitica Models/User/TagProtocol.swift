//
//  TagProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 06.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol TagProtocol: BaseModelProtocol {
    @objc var id: String? { get set }
    @objc var text: String? { get set }
    @objc var order: Int { get set }
}
