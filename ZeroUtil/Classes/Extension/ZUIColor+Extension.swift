//
//  ZUIColor+Extension.swift
//  Pods
//
//  Created by lyp on 2020/4/3.
//  Copyright © 2020 lyp@zurp.date. All rights reserved.
//

import Foundation

public extension UIColor {
    
    convenience init(hexStr: String, alpha: CGFloat? = nil) {
        var hex = hexStr
        if hex.hasPrefix("0X") || hex.hasPrefix("0x") {
            hex = String(hex.suffix(hex.count - 2))
        } else if hex.hasPrefix("#") {
            hex = String(hex.suffix(hex.count - 1))
        }

        var hexValue: UInt32 = 0
        if Scanner(string: hex).scanHexInt32(&hexValue) {
            if hex.count == 8 {
                self.init(hex6: hexValue >> 4, alpha: alpha ?? (CGFloat(hexValue & 0xFF) / 0xFF))
            } else {
                self.init(hex6: hexValue, alpha: alpha ?? 1.0)
            }
        } else {
            self.init(cgColor: ZUIColor.defaultColor.withAlphaComponent(alpha ?? 1.0).cgColor)
        }
    }
    
    convenience init(hex6: UInt32, alpha: CGFloat = 1) {
        let r = (hex6 & 0xFF0000) >> 16
        let g = (hex6 & 0x00FF00) >> 8
        let b = (hex6 & 0x0000FF)
        self.init(red: CGFloat(r) / 0xFF, green: CGFloat(g) / 0xFF, blue: CGFloat(b) / 0xFF, alpha: alpha)
    }
    
    var z: ZUIColor { return ZUIColor(target: self) }
}

open class ZUIColor: NSObject {
    public static var defaultColor = UIColor.black
    public let target: UIColor
    
    public init(target: UIColor) {
        self.target = target
    }
    
    open var invertColor: UIColor {
        let rgba = self.rgba
        return UIColor(red: 1 - rgba.red, green: 1 - rgba.green, blue: 1 - rgba.blue, alpha: rgba.alpha)
    }
    
    open var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, alpha: CGFloat = 1
        target.getRed(&r, green: &g, blue: &b, alpha: &alpha)
        return (r, g, b, alpha)
    }
}
