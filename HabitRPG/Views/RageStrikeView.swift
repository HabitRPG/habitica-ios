//
//  RageStrikeView.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class RageStrikeView: UIView {
    
    let backgroundView = UIImageView()
    let borderView = UIImageView(image: #imageLiteral(resourceName: "rage_strike_pending"))
    
    var isActive = false {
        didSet {
            if isActive {
                borderView.image = #imageLiteral(resourceName: "rage_strike_active")
            } else {
                borderView.image = #imageLiteral(resourceName: "rage_strike_pending")
            }
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        isUserInteractionEnabled = true
        
        backgroundView.contentMode = .center
        borderView.contentMode = .center
        
        addSubview(backgroundView)
        addSubview(borderView)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 84, height: 84)
    }
    
    @objc
    func viewTapped() {
        if isActive {
            
        } else {
            let alertController = HabiticaAlertController.alert(title: NSLocalizedString("Pending Strike", comment: ""), message: NSLocalizedString("", comment: ""))
            alertController.titleBackgroundColor = UIColor.orange50()
            alertController.addCloseAction()
            alertController.show()
            alertController.titleLabel.textColor = .white
        }
    }
}
