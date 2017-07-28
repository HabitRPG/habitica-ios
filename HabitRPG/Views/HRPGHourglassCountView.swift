//
//  HRPGHourglassCountView.swift
//  Habitica
//
//  Created by Elliot Schrock on 7/13/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class HRPGHourglassCountView: HRPGCurrencyCountView {
    
    override func configureViews() {
        countLabel.textColor = UIColor.brown
        currencyImageView.image = UIImage(named: "hourglass")
        
        super.configureViews()
    }

}
