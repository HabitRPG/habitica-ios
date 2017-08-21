//
//  HRPGItemStatsView.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/18/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class HRPGItemStatsView: UIView {
    var item: ShopItem?
    @IBOutlet weak var strLabel: UILabel!
    @IBOutlet weak var strStatLabel: UILabel!
    @IBOutlet weak var conLabel: UILabel!
    @IBOutlet weak var conStatLabel: UILabel!
    @IBOutlet weak var perLabel: UILabel!
    @IBOutlet weak var perStatLabel: UILabel!
    @IBOutlet weak var intLabel: UILabel!
    @IBOutlet weak var intStatLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 154, height: 36))
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func didMoveToWindow() {
        if let shopItem = item {
            
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func setupView() {
        if let view = viewFromNibForClass() {
            translatesAutoresizingMaskIntoConstraints = false
            
            view.frame = bounds
            addSubview(view)
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // Loads a XIB file into a view and returns this view.
    private func viewFromNibForClass() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        
        return view
    }

}
