//
//  UIColorExtension.swift
//  HEXColor
//
//  Created by R0CKSTAR on 6/13/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//
import UIKit

/**
 MissingHashMarkAsPrefix:   "Invalid RGB string, missing '#' as prefix"
 UnableToScanHexValue:      "Scan hex error"
 MismatchedHexStringLength: "Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8"
 */
public enum UIColorInputError: Error {
    case missingHashMarkAsPrefix,
    unableToScanHexValue,
    mismatchedHexStringLength
}

extension UIColor {
    /**
     The shorthand three-digit hexadecimal representation of color.
     #RGB defines to the color #RRGGBB.
     
     - parameter hex3: Three-digit hexadecimal value.
     - parameter alpha: 0.0 - 1.0. The default is 1.0.
     */
    public convenience init(hex3: UInt16, alpha: CGFloat = 1) {
        let divisor = CGFloat(15)
        let red     = CGFloat((hex3 & 0xF00) >> 8) / divisor
        let green   = CGFloat((hex3 & 0x0F0) >> 4) / divisor
        let blue    = CGFloat( hex3 & 0x00F      ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     The shorthand four-digit hexadecimal representation of color with alpha.
     #RGBA defines to the color #RRGGBBAA.
     
     - parameter hex4: Four-digit hexadecimal value.
     */
    public convenience init(hex4: UInt16) {
        let divisor = CGFloat(15)
        let red     = CGFloat((hex4 & 0xF000) >> 12) / divisor
        let green   = CGFloat((hex4 & 0x0F00) >>  8) / divisor
        let blue    = CGFloat((hex4 & 0x00F0) >>  4) / divisor
        let alpha   = CGFloat( hex4 & 0x000F       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     The six-digit hexadecimal representation of color of the form #RRGGBB.
     
     - parameter hex6: Six-digit hexadecimal value.
     */
    public convenience init(hex6: UInt32, alpha: CGFloat = 1) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((hex6 & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( hex6 & 0x0000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     The six-digit hexadecimal representation of color with alpha of the form #RRGGBBAA.
     
     - parameter hex8: Eight-digit hexadecimal value.
     */
    public convenience init(hex8: UInt32) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex8 & 0xFF000000) >> 24) / divisor
        let green   = CGFloat((hex8 & 0x00FF0000) >> 16) / divisor
        let blue    = CGFloat((hex8 & 0x0000FF00) >>  8) / divisor
        let alpha   = CGFloat( hex8 & 0x000000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     The rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB, throws error.
     
     - parameter rgba: String value.
     */
    public convenience init(rgba_throws rgba: String) throws {
        guard rgba.hasPrefix("#") else {
            throw UIColorInputError.missingHashMarkAsPrefix
        }
        
        let hexString: String = rgba.substring(from: rgba.index(rgba.startIndex, offsetBy: 1))
        var hexValue: UInt32 = 0
        
        guard Scanner(string: hexString).scanHexInt32(&hexValue) else {
            throw UIColorInputError.unableToScanHexValue
        }
        
        switch hexString.count {
        case 3:
            self.init(hex3: UInt16(hexValue))
        case 4:
            self.init(hex4: UInt16(hexValue))
        case 6:
            self.init(hex6: hexValue)
        case 8:
            self.init(hex8: hexValue)
        default:
            throw UIColorInputError.mismatchedHexStringLength
        }
    }
    
    /**
     The rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB, fails to default color.
     
     - parameter rgba: String value.
     */
    public convenience init(_ rgba: String, defaultColor: UIColor = UIColor.clear) {
        guard let color = try? UIColor(rgba_throws: rgba) else {
            self.init(cgColor: defaultColor.cgColor)
            return
        }
        self.init(cgColor: color.cgColor)
    }
    
    /**
     The color associated with a specific task value. Defaults to blue50.

     - parameter taskValue: NSNumber value.
     */
    @objc public static func forTaskValue(_ taskValue: NSNumber) -> UIColor {
        let intValue: Int = taskValue.intValue
        if intValue < -20 {
            return UIColor.darkRed50()
        } else if intValue < -10 {
            return UIColor.red50()
        } else if intValue < -1 {
            return UIColor.orange50()
        } else if intValue < 1 {
            return UIColor.yellow50()
        } else if intValue < 5 {
            return UIColor.green50()
        } else if intValue < 10 {
            return UIColor.teal50()
        } else {
            return UIColor.blue50()
        }
    }
    
    /**
     The light color associated with a specific task value. Defaults to blue100.
     
     - parameter taskValue: NSNumber value.
     */
    @objc public static func forTaskValueLight(_ taskValue: NSNumber) -> UIColor {
        let intValue: Int = taskValue.intValue
        if intValue < -20 {
            return UIColor.darkRed100()
        } else if intValue < -10 {
            return UIColor.red100()
        } else if intValue < -1 {
            return UIColor.orange100()
        } else if intValue < 1 {
            return UIColor.yellow100()
        } else if intValue < 5 {
            return UIColor.green100()
        } else if intValue < 10 {
            return UIColor.teal100()
        } else {
            return UIColor.blue100()
        }
    }
    
    /**
     Hex string of a UIColor instance.
     
     - parameter includeAlpha: Whether the alpha should be included.
     */
    public func hexString(_ includeAlpha: Bool = true) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        if includeAlpha {
            return String(format: "#%02X%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255), Int(alpha * 255))
        } else {
            return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
        }
    }
    
    func lighter(by percentage: CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat=30.0) -> UIColor? {
        var red: CGFloat=0, green: CGFloat=0, blue: CGFloat=0, alpha: CGFloat=0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
    
    func isLight() -> Bool {
        // algorithm from: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
        guard let components = self.cgColor.components else {
            return false
        }
        var brightness: CGFloat = 0.0
        if components.count >= 3 {
            brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        } else {
            brightness = components[0]
        }
        
        if brightness < 0.5 {
            return false
        } else {
            return true
        }
    }
}

extension String {
    /**
     Convert argb string to rgba string.
     */
    public func argb2rgba() -> String? {
        guard self.hasPrefix("#") else {
            return nil
        }
        
        let hexString: String = self.substring(from: self.index(self.startIndex, offsetBy: 1))
        switch hexString.count {
        case 4:
            return "#"
                + hexString.substring(from: self.index(self.startIndex, offsetBy: 1))
                + hexString.substring(to: self.index(self.startIndex, offsetBy: 1))
        case 8:
            return "#"
                + hexString.substring(from: self.index(self.startIndex, offsetBy: 2))
                + hexString.substring(to: self.index(self.startIndex, offsetBy: 2))
        default:
            return nil
        }
    }
}
