//
//  FlagView.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.11.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

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

    @IBInspectable var flagColor: UIColor = UIColor.gray400 {
        didSet {
            label.backgroundColor = flagColor
            flapView.tintColor = flagColor

            if self.automaticTextColor {
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0
                if flagColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
                    if red*0.299 + green*0.587 + blue*0.114 > 0.829 {
                        self.label.textColor = .black
                    } else {
                        self.label.textColor = .white
                    }
                }
            }
        }
    }

    @IBInspectable var textColor: UIColor = UIColor.white {
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
        addSubview(label)
        addSubview(flapView)
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = textColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        flapView.frame = CGRect(x: 0, y: 0, width: 9, height: 24)
        label.frame = CGRect(x: 9, y: 0, width: frame.size.width-9, height: frame.size.height)
    }

    override var intrinsicContentSize: CGSize {
        if self.isHidden {
            return CGSize(width: 0, height: 0)
        }
        let originalSize = label.intrinsicContentSize
        let width = originalSize.width+20
        let height = CGFloat(24)
        return CGSize(width: width, height: height)
    }
}
