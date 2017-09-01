//
//  HRPGShopModalBgView.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/12/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

@IBDesignable
class HRPGShopModalBgView: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var maxHeightConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Private Helper Methods
    
    private func setupView() {
        if let view = viewFromNibForClass() {
            view.frame = bounds
            
            view.autoresizingMask = [
                UIViewAutoresizing.flexibleWidth,
                UIViewAutoresizing.flexibleHeight
            ]
            
            addSubview(view)
        }
        
        clipsToBounds = true
        layer.cornerRadius = 12
    }
}
