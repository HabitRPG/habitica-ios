//
//  HRPGCloseableShopModalView.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/12/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

@IBDesignable
class HRPGCloseableShopModalView: UIView {
    @IBOutlet weak var shopModalBgView: HRPGShopModalBgView!
    
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
                UIView.AutoresizingMask.flexibleWidth,
                UIView.AutoresizingMask.flexibleHeight
            ]
            
            addSubview(view)
        }
    }
}
