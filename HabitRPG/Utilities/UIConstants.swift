//
//  UIConstants.swift
//  Habitica
//
//  Created by Phillip Thelen on 12.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import UIKit

class UIConstants {
    static var largeCornerRadius: CGFloat {
        if #available(iOS 26.0, *) {
            return 26
        } else {
            return 13
        }
    }
    
    static var mediumCornerRadius: CGFloat {
        if #available(iOS 26.0, *) {
            return 13
        } else {
            return 8
        }
    }
    
    static var smallCornerRadius: CGFloat {
        if #available(iOS 26.0, *) {
            return 8
        } else {
            return 4
        }
    }
}
