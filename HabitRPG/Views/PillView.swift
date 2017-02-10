//
//  PillView.swift
//  Habitica
//
//  Created by Phillip Thelen on 09/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

@IBDesignable
class PillView: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        setPillColor(.gray400())
        textAlignment = .center
        self.font = UIFont.preferredFont(forTextStyle: .caption1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.height / 2
    }
    
    public func setPillColor(_ color: UIColor) {
        layer.backgroundColor = color.cgColor
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            if red*0.299 + green*0.587 + blue*0.114 > 0.729 {
                self.textColor = .black
            } else {
                self.textColor = .white
            }
        }

    }
    
    override var intrinsicContentSize: CGSize {
        get {
            let originalSize = super.intrinsicContentSize
            return CGSize(width: originalSize.width+24, height: originalSize.height+12)
        }
    }

}
