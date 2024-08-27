//
//  FlagView.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.11.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import UIKit

@IBDesignable
class FlagView: UIView {
    
    @IBInspectable var text: String? {
        get {
            return self.label.text
        }
        set {
            self.label.text = newValue
        }
    }

    @IBInspectable var textColor: UIColor = UIColor.teal1 {
        didSet {
            self.label.textColor = textColor
        }
    }

    @IBInspectable var automaticTextColor: Bool = true {
        didSet {
            self.setNeedsLayout()
        }
    }

    override var isHidden: Bool {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }

    private let gradientView = GradientView()
    private let label = UILabel()
    private let flapView = UIImageView(image: Asset.flagFlap.image)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    func setupView() {
        addSubview(gradientView)
        addSubview(label)
        addSubview(flapView)
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = textColor
        
        gradientView.horizontalMode = true
        gradientView.startColor = UIColor.teal100
        gradientView.endColor = UIColor.blue100
        flapView.tintColor = UIColor.teal100
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        flapView.frame = CGRect(x: 0, y: 0, width: 4, height: 24)
        gradientView.frame = CGRect(x: 4, y: 0, width: frame.size.width-4, height: frame.size.height)
        label.frame = CGRect(x: 4, y: 0, width: frame.size.width-4, height: frame.size.height)
    }

    override var intrinsicContentSize: CGSize {
        if self.isHidden {
            return CGSize(width: 0, height: 0)
        }
        let originalSize = label.intrinsicContentSize
        let width = originalSize.width+15
        let height = CGFloat(24)
        return CGSize(width: width, height: height)
    }
}
