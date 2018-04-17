//
//  NPCBannerView.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/13/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class NPCBannerView: UIView {
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var foregroundImageView: UIImageView!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var npcNameLabel: UILabel!
    @IBOutlet weak var plaqueImageView: UIImageView!
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
            
            plaqueImageView.image = UIImage(named: "Nameplate")?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 21))
            
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
            self.bgImageView.image = image?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: UIImageResizingMode.tile)
        }
        foregroundImageView.setImagewith(name: identifier + "_scene"+spriteSuffix)
    }
    
    func setNotes(_ notes: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        let attrString = NSMutableAttributedString(string: notes)
        attrString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length:   attrString.length))
        self.notesLabel.attributedText = attrString
    }
}
