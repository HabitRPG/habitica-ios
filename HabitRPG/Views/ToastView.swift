//
//  CRToast.swift
//  CRToast
//
//  Created by Collin Ruffenach on 11/6/14.
//  Copyright (c) 2014 Notion. All rights reserved.
//

import UIKit

class ToastView: UIView {
        
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainStackview: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var priceContainer: UIView!
    
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var bottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var topSpacing: NSLayoutConstraint!
    @IBOutlet weak var leadingSpacing: NSLayoutConstraint!
    @IBOutlet weak var trailingSpacing: NSLayoutConstraint!
    
    @IBOutlet weak var leftImageWidth: NSLayoutConstraint!
    @IBOutlet weak var leftImageHeight: NSLayoutConstraint!
    @IBOutlet weak var priceContainerWidth: NSLayoutConstraint!
    
    var options: ToastOptions = ToastOptions()
    
    public convenience init(title: String, subtitle: String, background: ToastColor) {
        self.init(frame: CGRect.zero)
        options.title = title
        options.subtitle = subtitle
        options.backgroundColor = background
        loadOptions()
    }
    
    public convenience init(title: String, background: ToastColor) {
        self.init(frame: CGRect.zero)
        options.title = title
        options.backgroundColor = background
        loadOptions()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureViews()
    }
    
    private func configureViews() {
        self.backgroundColor = .clear
        if let view = viewFromNibForClass() {
            translatesAutoresizingMaskIntoConstraints = false
            
            view.frame = bounds
            addSubview(view)
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            
            backgroundView.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
            backgroundView.layer.borderWidth = 1
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
        loadOptions()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.layer.cornerRadius = backgroundView.frame.size.height/2
    }

    func loadOptions() {
        self.backgroundView.backgroundColor = options.backgroundColor.getUIColor()
        self.backgroundView.layer.borderColor = options.backgroundColor.getUIColor().darker(by: 10)?.cgColor

        topSpacing.constant = 6
        bottomSpacing.constant = 6
        leadingSpacing.constant = 8
        trailingSpacing.constant = 8
        if let title = self.options.title {
            titleLabel.isHidden = false
            titleLabel.text = title
            titleLabel.sizeToFit()
            titleLabel.numberOfLines = -1
            titleLabel.font = UIFont.systemFont(ofSize: 13)
        } else {
            titleLabel.isHidden = true
            titleLabel.text = nil
        }
        
        if let subtitle = self.options.subtitle {
            subtitleLabel.isHidden = false
            subtitleLabel.text = subtitle
            subtitleLabel.sizeToFit()
            subtitleLabel.numberOfLines = -1
            self.titleLabel.font = UIFont.systemFont(ofSize: 16)
        } else {
            subtitleLabel.isHidden = true
            subtitleLabel.text = nil
        }
        
        if let leftImage = self.options.leftImage {
            leftImageView.isHidden = false
            leftImageView.image = leftImage
            
            topSpacing.constant = 6
        } else {
            leftImageView.isHidden = true
            leftImageWidth.constant = 0
            leftImageHeight.priority = 500
        }
        
        priceContainerWidth.constant = 0
        
        self.setNeedsLayout()
        setNeedsUpdateConstraints()
        updateConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }
}
