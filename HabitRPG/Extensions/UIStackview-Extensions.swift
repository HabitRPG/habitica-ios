//
//  UIStackview-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 13.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import UIKit

extension UIStackView {
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach { view in view.removeFromSuperview() }
    }
}
