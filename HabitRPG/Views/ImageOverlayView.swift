//
//  ImageOverlayView.swift
//  Habitica
//
//  Created by Phillip Thelen on 13.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

class ImageOverlayView: HabiticaAlertController {
    
    private var imageView = UIImageView()
    private var imageHeightConstraint: NSLayoutConstraint?
    
    var imageName: String? {
        didSet {
            if let imageName = imageName {
                imageView.setImagewith(name: imageName)
            }
        }
    }
    
    var imageHeight: CGFloat? {
        get {
            return imageHeightConstraint?.constant
        }
        set {
            imageHeightConstraint?.constant = newValue ?? 0
        }
    }
    
    init(imageName: String, title: String?, message: String?) {
        super.init()
        self.title = title
        self.message = message
        self.imageName = imageName
        setupImageView()
        imageView.setImagewith(name: imageName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImageView()
    }

    private func setupImageView() {
        contentView = imageView
        imageView.contentMode = .center
        imageHeightConstraint = NSLayoutConstraint(item: imageView,
                                                   attribute: NSLayoutAttribute.height,
                                                   relatedBy: NSLayoutRelation.equal,
                                                   toItem: nil,
                                                   attribute: NSLayoutAttribute.notAnAttribute,
                                                   multiplier: 1,
                                                   constant: 100)
        if let constraint = imageHeightConstraint {
            imageView.addConstraint(constraint)
        }
    }
}

extension ImageOverlayView {
    @objc
    func addShareAction(handler: ((UIButton) -> Void)? = nil) {
        self.addAction(title: NSLocalizedString(L10n.share, comment: ""), handler: handler)
    }
}
