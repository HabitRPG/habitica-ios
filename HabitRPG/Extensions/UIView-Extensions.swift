//
//  UIView-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 01/03/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import Foundation

extension UIView {
    class func fromNib<T: UIView>() -> T? {
        guard let nibs = Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil) else {
            return nil
        }
        guard let view = nibs[0] as? T else {
            return nil
        }
        return view
    }
}
