//
//  SubscriptionOptionView.swift
//  Habitica
//
//  Created by Phillip Thelen on 07/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class SubscriptionOptionView: UITableViewCell {

    //swiftlint:disable private_outlet
    @IBOutlet weak var selectionView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    //swiftlint:enable private_outlet

    override func setSelected(_ selected: Bool, animated: Bool) {
        let animDuration = 0.3
        if selected {
            UIView.animate(withDuration: animDuration, animations: {[weak self] () in
                self?.selectionView.backgroundColor = .purple300()
                self?.selectionView.image = #imageLiteral(resourceName: "circle_selected")
            })
        } else {
            UIView.animate(withDuration: animDuration, animations: {[weak self] () in
                self?.selectionView.backgroundColor = .purple600()
                self?.selectionView.image = #imageLiteral(resourceName: "circle_unselected")
            })
        }
    }

}
