//
//  CALayer-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 08.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

extension CALayer {
    func replaceSublayers(with newSublayer: CALayer) {
        sublayers?.forEach({ sublayer in
            sublayer.removeFromSuperlayer()
        })
        insertSublayer(newSublayer, at: 0)
    }
}
