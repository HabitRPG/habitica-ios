//
//  HRPGShopBannerView.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/13/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class HRPGShopBannerView: UIView {
    @IBOutlet weak var shopBgImageView: UIImageView!
    @IBOutlet weak var shopForegroundImageView: UIImageView!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var shopPlaqueImageView: UIImageView!
    private var _shop: Shop?
    var shop: Shop? {
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
        }
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            notesLabel.sizeToFit()
            return CGSize(width: UIScreen.main.bounds.size.width, height: 167 + notesLabel.bounds.size.height)
        }
    }
    
    // Loads a XIB file into a view and returns this view.
    private func viewFromNibForClass() -> UIView? {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        
        return view
    }
    
    private func setupShop() {
        shopPlaqueImageView.image = UIImage(named: "Nameplate")?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 21))
        if let unwrappedShop = shop, let identifier = unwrappedShop.identifier {
            HRPGManager.shared().getImage(identifier + "_background", withFormat: "png", onSuccess: { (image) in
                self.shopBgImageView.image = image?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: UIImageResizingMode.tile)
            }, onError: {})
            HRPGManager.shared().setImage(identifier + "_scene", withFormat: "png", on: self.shopForegroundImageView)
            
            self.shopNameLabel.text = unwrappedShop.text
            
            if let notes = unwrappedShop.notes?.strippingHTML() {
                self.notesLabel.text = notes
            }
        }
    }

}
