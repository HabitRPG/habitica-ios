//
//  StableOverviewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

class StableOverviewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    func configure(item: StableOverviewItem) {
        imageView.setImagewith(name: item.imageName)
        textLabel.text = item.text
        countLabel.text = "\(item.numberOwned)/\(item.totalNumber)"
        
        countLabel.backgroundColor = UIColor.gray600()
        textLabel.textColor = UIColor.gray100()
        if item.numberOwned == 0 {
            countLabel.textColor = UIColor.gray400()
            textLabel.textColor = UIColor.gray400()
        } else if item.numberOwned == item.totalNumber {
            countLabel.backgroundColor = UIColor.green100()
            countLabel.textColor = .white
        } else {
            countLabel.textColor = UIColor.gray100()
        }
    }
    
}
