//
//  NPCBannerView.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/13/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class NPCBannerView: UIView {
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var foregroundImageView: UIImageView!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var npcNameLabel: UILabel!
    @IBOutlet weak var plaqueImageView: UIImageView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var bgWhiteView: UILabel!
    @objc var shop: ShopProtocol? {
        didSet {
            setupShop()
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
                UIView.AutoresizingMask.flexibleWidth,
                UIView.AutoresizingMask.flexibleHeight
            ]
            
            addSubview(view)
            
            plaqueImageView.image = UIImage(named: "Nameplate")?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 21))
            
            let theme = ThemeService.shared.theme
            gradientView.startColor = theme.windowBackgroundColor.withAlphaComponent(0.8)
            gradientView.endColor = theme.windowBackgroundColor
            notesLabel.backgroundColor = theme.windowBackgroundColor
            notesLabel.textColor = theme.primaryTextColor
            bgWhiteView.backgroundColor = theme.windowBackgroundColor
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
        if let unwrappedShop = shop, let identifier = unwrappedShop.identifier {
            setSprites(identifier: identifier)
            switch unwrappedShop.identifier {
            case .some("market"):
                self.npcNameLabel.text = "Alex"
            case .some("questShop"):
                self.npcNameLabel.text = "Ian"
            case .some("seasonalShop"):
                self.npcNameLabel.text = "Leslie"
            case .some("timeTravelersShop"):
                self.npcNameLabel.text = "Tyler & Vicky"
            default:
                self.npcNameLabel.text = unwrappedShop.text
            }
            
            if let notes = unwrappedShop.notes?.strippingHTML() {
                setNotes(notes)
            }
            self.invalidateIntrinsicContentSize()
        }
    }

    func setSprites(identifier: String) {
        let spriteSuffix = ConfigRepository().string(variable: .shopSpriteSuffix, defaultValue: "")
        ImageManager.getImage(name: identifier + "_background"+spriteSuffix) { (image, _) in
            self.bgImageView.image = image?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: UIImage.ResizingMode.tile)
        }
        foregroundImageView.setImagewith(name: identifier + "_scene"+spriteSuffix)
    }
    
    func setNotes(_ notes: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        let attrString = NSMutableAttributedString(string: notes)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attrString.length))
        self.notesLabel.attributedText = attrString
    }
}
