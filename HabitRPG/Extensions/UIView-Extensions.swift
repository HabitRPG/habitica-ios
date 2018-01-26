//
//  UIView-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 01/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation

extension UIView {
    
    class func fromNib<T: UIView>(nibName: String? = nil) -> T? {
        guard let nibs = Bundle.main.loadNibNamed(nibName ?? String(describing: T.self), owner: nil, options: nil) else {
            return nil
        }
        guard let view = nibs[0] as? T else {
            return nil
        }
        return view
    }
    
    @objc
    class func loadFromNib(nibName: String) -> UIView? {
        guard let nibs = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil) else {
            return nil
        }
        return nibs[0] as? UIView
    }
    
    @objc
    func viewFromNibForClass() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        
        return view
    }
}
