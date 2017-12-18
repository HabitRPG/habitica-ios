//
//  HRPGShopBannerView.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/13/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class HRPGShopBannerView: UIView {
    @IBOutlet weak var shopBgImageView: UIImageView!
    @IBOutlet weak var shopForegroundImageView: UIImageView!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var shopPlaqueImageView: UIImageView!
    @IBOutlet weak var gradientView: GradientView!
    private var _shop: Shop?
    @objc var shop: Shop? {
        set(newShop) {
            _shop = newShop
            setupShop()
        }
        get {
            return _shop
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
        if let view = viewFromNibForClass() {
            view.frame = bounds
            
            view.autoresizingMask = [
                UIViewAutoresizing.flexibleWidth,
                UIViewAutoresizing.flexibleHeight
            ]
            
            addSubview(view)
            
            gradientView.startColor = UIColor.white.withAlphaComponent(0.8)
            gradientView.endColor = UIColor.white
        }
    }
    
    override var intrinsicContentSize: CGSize {
        notesLabel.sizeToFit()
        var labelHeight: CGFloat = notesLabel.bounds.size.height
        if labelHeight == 0 {
            labelHeight = 60
        }
        return CGSize(width: UIScreen.main.bounds.size.width, height: 140 + labelHeight)
    }
    
    private func setupShop() {
        let shopSpriteSuffix = ConfigRepository().string(variable: .shopSpriteSuffix, defaultValue: "")
        shopPlaqueImageView.image = UIImage(named: "Nameplate")?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 21))
        if let unwrappedShop = shop, let identifier = unwrappedShop.identifier {
            HRPGManager.shared().getImage(identifier + "_background"+shopSpriteSuffix, withFormat: "png", onSuccess: { (image) in
                self.shopBgImageView.image = image?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: UIImageResizingMode.tile)
            }, onError: {})
            HRPGManager.shared().setImage(identifier + "_scene"+shopSpriteSuffix, withFormat: "png", on: self.shopForegroundImageView)
            
            switch unwrappedShop.identifier {
            case .some("market"):
                self.shopNameLabel.text = "Alex"
            case .some("questShop"):
                self.shopNameLabel.text = "Ian"
            case .some("seasonalShop"):
                self.shopNameLabel.text = "Leslie"
            case .some("timeTravelersShop"):
                self.shopNameLabel.text = "Tyler & Vicky"
            default:
                self.shopNameLabel.text = unwrappedShop.text
            }
            
            if let notes = unwrappedShop.notes?.strippingHTML() {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 4
                
                let attrString = NSMutableAttributedString(string: notes)
                attrString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length:   attrString.length))
                self.notesLabel.attributedText = attrString
            }
            self.invalidateIntrinsicContentSize()
        }
    }

}
