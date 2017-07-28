//
//  HRPGGoldCountView.swift
//  Habitica
//
//  Created by Elliot Schrock on 7/13/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class HRPGGoldCountView: HRPGCurrencyCountView {

    override func configureViews() {
        countLabel.textColor = UIColor.yellow10()
        currencyImageView.image = UIImage(named: "gold_coin")
        
        super.configureViews()
    }

}
