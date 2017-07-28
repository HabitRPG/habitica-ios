//
//  HRPGGemCountView.swift
//  Habitica
//
//  Created by Elliot Schrock on 7/13/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class HRPGGemCountView: HRPGCurrencyCountView {
    
    override func configureViews() {
        countLabel.textColor = UIColor.green10()
        currencyImageView.image = UIImage(named: "Gem")
        
        super.configureViews()
    }

}
