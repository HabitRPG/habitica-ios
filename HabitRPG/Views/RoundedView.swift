//
//  RoundedView.swift
//  Habitica
//
//  Created by Phillip on 30.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class RoundedView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.height / 2.0
    }
    
    
}
