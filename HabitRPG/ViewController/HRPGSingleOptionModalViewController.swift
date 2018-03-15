//
//  HRPGSingleOptionModalViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/11/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class HRPGSingleOptionModalViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton?
    @IBOutlet weak var imageTextView: HRPGSimpleShopItemView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss(animated:completion:)))
        view.addGestureRecognizer(tap)

        styleViews()
    }
    
    func styleViews() {
        titleLabel.superview?.bringSubview(toFront: titleLabel)
        if let button = actionButton {
            button.superview?.bringSubview(toFront: button)
        }
        titleLabel.superview?.bringSubview(toFront: imageTextView)
        
        actionButton?.layer.borderWidth = 0.5
        actionButton?.layer.borderColor = UIColor.gray400().cgColor
        actionButton?.setTitleColor(UIColor.purple400(), for: UIControlState.normal)
        
        imageTextView.shopItemTitleLabel.font = UIFont.systemFont(ofSize: 15)
        imageTextView.shopItemTitleLabel.textColor = UIColor.gray200()
    }
}
