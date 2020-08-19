//
//  AbbreviatedNumberLabel.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation

class AbbreviatedNumberLabel: UILabel {
    override var text: String? {
        get { super.text }
        set {
            super.text = newValue?.stringWithAbbreviatedNumber()
        }
    }
}
