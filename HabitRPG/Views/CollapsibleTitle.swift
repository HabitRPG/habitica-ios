//
//  CollapsibleTitle.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

@IBDesignable
class CollapsibleTitle: UILabel {
    
    private var carretIconView = UIImageView(image: #imageLiteral(resourceName: "carret_up"))
    
    var tapAction: (() -> Void)?
    
    var isCollapsed = false {
        didSet {
            if isCollapsed {
                carretIconView.image = #imageLiteral(resourceName: "carret_down")
            } else {
                carretIconView.image = #imageLiteral(resourceName: "carret_up")
            }
        }
    }
    
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
        addSubview(carretIconView)
        carretIconView.contentMode = .center
                
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }
    
    override func layoutSubviews() {
        carretIconView.frame = CGRect(x: bounds.size.width-24, y: bounds.size.height/2-12, width: 24, height: 24)
    }
    
    @objc
    func viewTapped() {
        if let action = self.tapAction {
            action()
        }
    }
}
