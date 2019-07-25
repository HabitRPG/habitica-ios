//
//  BadgeLabel.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

class BadgeView: PaddedLabel {
    
    var number: Int = 0 {
        didSet {
            text = String(number)
            isHidden = number == 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    internal func setupView() {
        font = CustomFontMetrics.scaledSystemFont(ofSize: 13)
        textAlignment = .center
        if #available(iOS 10.0, *) {
            adjustsFontForContentSizeCategory = true
        }
        verticalPadding = 2
        horizontalPadding = 7
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cornerRadius = frame.size.height / 2
    }
    
}
