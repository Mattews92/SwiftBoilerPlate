//
//  UIColorExtension.swift
//  Mathews
//
//  Created by Mathews on 04/10/17.
//  Copyright © 2017 Mathews. All rights reserved.
//

import Foundation
import UIKit


// MARK: - UIColor extension
extension UIColor {
    
    
    /// Converts RGB Hexcode into UIcolor
    ///
    /// - Parameters:
    ///   - colorCode: RGB Hexcode
    ///   - alpha: alpha value of UIColor
    /// - Returns: UIColor corresponding to input RGB
    func color(fromHex colorCode: String, alpha: Float = 1.0) -> UIColor {
        let hexCode = colorCode.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexCode)
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = CGFloat(Float(Int(color >> 16) & mask) / 255.0)
        let g = CGFloat(Float(Int(color >> 8) & mask) / 255.0 )
        let b = CGFloat(Float(Int(color) & mask) / 255.0 )
        return UIColor(red: r, green: g, blue: b, alpha: CGFloat(alpha))
    }
    
    /// Inverses the UIColor
    ///
    /// - Returns: returns the inverse UIColor of the current instance
    func inverseColor() -> UIColor {
        var alpha: CGFloat = 0
        var white: CGFloat = 0
        if self.getWhite(&white, alpha: &alpha) {
            return UIColor(white: 1.0 - white, alpha: alpha)
        }
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: 1.0 - hue, saturation: 1.0 - saturation, brightness: 1.0 - brightness, alpha: alpha)
        }
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue, alpha: alpha)
        }
        return UIColor.white
    }

}
