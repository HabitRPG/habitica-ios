//
//  Quest-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

extension Quest {
    
    @objc var uicolorDark: UIColor {
        return UIColor.init(colorDark ?? "", defaultColor: UIColor.clear)
    }
    
    @objc var uicolorMedium: UIColor {
        return UIColor.init(colorMedium ?? "", defaultColor: UIColor.clear)
    }
    
    @objc var uicolorLight: UIColor {
        return UIColor.init(colorLight ?? "", defaultColor: UIColor.clear)
    }
    
    @objc var uicolorExtraLight: UIColor {
        return UIColor.init(colorExtraLight ?? "", defaultColor: UIColor.clear)
    }
}
