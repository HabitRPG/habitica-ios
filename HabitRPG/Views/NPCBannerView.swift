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
    @IBOutlet weak var bgImageView: NetworkImageView!
    @IBOutlet weak var foregroundImageView: NetworkImageView!
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
            
        }
    }
    
    @objc
    func applyTheme(backgroundColor: UIColor) {
        let theme = ThemeService.shared.theme
        gradientView.startColor = backgroundColor.withAlphaComponent(0.8)
        gradientView.endColor = backgroundColor
        notesLabel.backgroundColor = backgroundColor
        notesLabel.textColor = theme.primaryTextColor
        bgWhiteView.backgroundColor = backgroundColor
        self.backgroundColor = backgroundColor
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
            setNPCName(identifier: identifier)
            
            if let notes = unwrappedShop.notes?.stripHTML() {
                setNotes(notes)
            }
            self.invalidateIntrinsicContentSize()
        }
    }
    
    @objc
    func setNPCName(identifier: String) {
        switch identifier {
        case "market":
            self.npcNameLabel.text = "Alex"
        case "questShop":
            self.npcNameLabel.text = "Ian"
        case "seasonalShop":
            self.npcNameLabel.text = "Leslie"
        case "timeTravelersShop":
            self.npcNameLabel.text = "Tyler & Vicky"
        default:
            self.npcNameLabel.text = ""
        }
    }

    @objc
    func setSprites(identifier: String) {
        var spriteSuffix = ConfigRepository.shared.string(variable: .shopSpriteSuffix, defaultValue: "")
        if (!spriteSuffix.starts(with: "_")) {
            spriteSuffix = "_" + spriteSuffix
        }
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
