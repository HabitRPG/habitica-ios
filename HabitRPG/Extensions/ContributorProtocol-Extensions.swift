//
//  ContributorProtocol-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

extension ContributorProtocol {
    
    var color: UIColor {
        return UIColor.contributorColor(for: level)
    }
    
}
