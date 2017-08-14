//
//  CRToast.swift
//  CRToast
//
//  Created by Collin Ruffenach on 11/6/14.
//  Copyright (c) 2014 Notion. All rights reserved.
//

import UIKit

class ToastView: UIView {
        
    var titleLabel = UILabel()
    var subtitleLabel = UILabel()
    var leftImageView = UIImageView()
    var rightImageView = UIImageView()
    
    var options: ToastOptions = ToastOptions()
    
    func loadOptions() {
        self.backgroundColor = options.backgroundColor.getUIColor()
        
        if let title = self.options.title {
            self.titleLabel.isHidden = false
            self.titleLabel.text = title
            self.titleLabel.sizeToFit()
            self.titleLabel.numberOfLines = -1
        } else {
            self.titleLabel.isHidden = true
        }
        
        if let subtitle = self.options.subtitle {
            subtitleLabel.isHidden = false
            subtitleLabel.text = subtitle
            subtitleLabel.sizeToFit()
            subtitleLabel.numberOfLines = -1
        } else {
            subtitleLabel.isHidden = true
        }
        
        if let leftImage = self.options.leftImage {
            leftImageView.isHidden = false
            leftImageView.image = leftImage
            leftImageView.sizeToFit()
        } else {
            leftImageView.isHidden = true
        }
        
        if let rightImage = self.options.rightImage {
            rightImageView.image = rightImage
            rightImageView.sizeToFit()
            rightImageView.isHidden = false
        } else {
            rightImageView.isHidden = true
        }
        
        self.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
