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
        
        let hexString: String = String(rgba.dropFirst())
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
    @objc
    public static func forTaskValue(_ taskValue: Float) -> UIColor {
        if taskValue < -20 {
            return UIColor.maroon50
        } else if taskValue < -10 {
            return UIColor.red50
        } else if taskValue < -1 {
            return UIColor.orange50
        } else if taskValue < 1 {
            return UIColor.yellow50
        } else if taskValue < 5 {
            return UIColor.green50
        } else if taskValue < 10 {
            return UIColor.teal50
        } else {
            return UIColor.blue50
        }
    }
    
    /**
     The dark color associated with a specific task value. Defaults to blue50.
     
     - parameter taskValue: NSNumber value.
     */
    @objc
    public static func forTaskValueDark(_ taskValue: Float) -> UIColor {
        if taskValue < -20 {
            return UIColor.maroon10
        } else if taskValue < -10 {
            return UIColor.red10
        } else if taskValue < -1 {
            return UIColor.orange10
        } else if taskValue < 1 {
            return UIColor.yellow10
        } else if taskValue < 5 {
            return UIColor.green10
        } else if taskValue < 10 {
            return UIColor.teal10
        } else {
            return UIColor.blue10
        }
    }
    
    /**
     The light color associated with a specific task value. Defaults to blue100.
     
     - parameter taskValue: NSNumber value.
     */
    @objc
    public static func forTaskValueLight(_ taskValue: Float) -> UIColor {
        if taskValue < -20 {
            return UIColor.maroon100
        } else if taskValue < -10 {
            return UIColor.red100
        } else if taskValue < -1 {
            return UIColor.orange100
        } else if taskValue < 1 {
            return UIColor.yellow100
        } else if taskValue < 5 {
            return UIColor.green100
        } else if taskValue < 10 {
            return UIColor.teal100
        } else {
            return UIColor.blue100
        }
    }
    
    /**
     The extra light color associated with a specific task value. Defaults to blue500.
     
     - parameter taskValue: NSNumber value.
     */
    @objc
    public static func forTaskValueExtraLight(_ taskValue: Float) -> UIColor {
        if taskValue < -20 {
            return UIColor.maroon500
        } else if taskValue < -10 {
            return UIColor.red500
        } else if taskValue < -1 {
            return UIColor.orange500
        } else if taskValue < 1 {
            return UIColor.yellow500
        } else if taskValue < 5 {
            return UIColor.green500
        } else if taskValue < 10 {
            return UIColor.teal500
        } else {
            return UIColor.blue500
        }
    }
    
    /**
     The darkest color associated with a specific task value. Defaults to blue50.
     
     - parameter taskValue: NSNumber value.
     */
    @objc
    public static func forTaskValueDarkest(_ taskValue: Float) -> UIColor {
        if taskValue < -20 {
            return UIColor.red1
        } else if taskValue < -10 {
            return UIColor.red1
        } else if taskValue < -1 {
            return UIColor.orange1
        } else if taskValue < 1 {
            return UIColor.yellow1
        } else if taskValue < 5 {
            return UIColor.green1
        } else if taskValue < 10 {
            return UIColor.teal1
        } else {
            return UIColor.blue1
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
    
func lighter(by percentage: CGFloat=30.0) -> UIColor {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat=30.0) -> UIColor {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat=30.0) -> UIColor {
        var red: CGFloat=0, green: CGFloat=0, blue: CGFloat=0, alpha: CGFloat=0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return self
        }
    }
    
    var brightness: CGFloat {
        // algorithm from: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
        guard let components = self.cgColor.components else {
            return 0.0
        }
        var brightness: CGFloat = 0.0
        if components.count >= 3 {
            brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        } else {
            brightness = components[0]
        }
        
        return brightness
    }
    
    func isLight() -> Bool {
        if brightness < 0.65 {
            return false
        } else {
            return true
        }
    }
    
    func difference(between otherColor: UIColor) -> CGFloat {
        guard let components = self.cgColor.components else {
            return 0.0
        }
        guard let otherComponents = otherColor.cgColor.components else {
            return 0.0
        }
        let red = components[0]
        let otherRed = otherComponents[0]
        let green = components.count >= 3 ? components[1] : components[0]
        let otherGreen = otherComponents.count >= 3 ? otherComponents[1] : otherComponents[0]
        let blue = components.count >= 3 ? components[2] : components[0]
        let otherBlue = otherComponents.count >= 3 ? otherComponents[2] : otherComponents[0]
        
        return (
            (max(red, otherRed) - min(red, otherRed)) +
            (max(green, otherGreen) - min(green, otherGreen)) +
            (max(blue, otherBlue) - min(blue, otherBlue))
        )
    }
    
    func blend(with infusion: UIColor, alpha: CGFloat) -> UIColor {
        let alpha2 = min(1.0, max(0, alpha))
        let beta = 1.0 - alpha2

        var r1: CGFloat = 0, r2: CGFloat = 0
        var g1: CGFloat = 0, g2: CGFloat = 0
        var b1: CGFloat = 0, b2: CGFloat = 0
        var a1: CGFloat = 0, a2: CGFloat = 0
        if getRed(&r1, green: &g1, blue: &b1, alpha: &a1) &&
            infusion.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) {
            let red     = r1 * beta + r2 * alpha2
            let green   = g1 * beta + g2 * alpha2
            let blue    = b1 * beta + b2 * alpha2
            let alpha   = a1 * beta + a2 * alpha2
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        return self
    }
}

extension UIColor {
  static func == (left: UIColor, right: UIColor) -> Bool {
    var r1: CGFloat = 0
    var g1: CGFloat = 0
    var b1: CGFloat = 0
    var a1: CGFloat = 0
    left.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    var r2: CGFloat = 0
    var g2: CGFloat = 0
    var b2: CGFloat = 0
    var a2: CGFloat = 0
    right.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
    return r1 == r2 && g1 == g2 && b1 == b2 && a1 == a2
  }
}
func == (left: UIColor?, right: UIColor?) -> Bool {
  let left = left ?? .clear
  let right = right ?? .clear
  return left == right
}
