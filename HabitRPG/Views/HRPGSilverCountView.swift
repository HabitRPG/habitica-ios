//
//  HRPGSilverCountView.swift
//  Habitica
//
//  Created by Elliot Schrock on 7/13/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class HRPGSilverCountView: HRPGCurrencyCountView {
    
    override func configureViews() {
        countLabel.textColor = UIColor.gray50()
        currencyImageView.image = UIImage(named: "silver_coin")
        
        super.configureViews()
    }

}
