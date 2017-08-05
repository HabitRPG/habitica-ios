//
//  HRPGCurrencyItemCollectionViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 7/31/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class HRPGCurrencyItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var currencyCountView: HRPGCurrencyCountView!
    @IBOutlet weak var itemImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.clipsToBounds = true
        containerView.cornerRadius = 4
    }
    
}
