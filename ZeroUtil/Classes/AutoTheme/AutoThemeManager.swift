//
//  AutoThemeManager.swift
//  Pods
//
//  Created by lyp on 2020/4/16.
//  Copyright © 2020 lyp@zurp.date. All rights reserved.
//

import Foundation

open class AutoThemeManager {
    
    public init() {
        
    }
    
    open func colorParser(content: String, index: Int, default: UIColor) -> (items: [String], isSuccess: Bool) {
        if let hex = content.split(separator: "_").z[safe: index] {
            return ([String(hex)], true)
        }
        return ([content], false)
    }
    
    open func fontParser(content: String, index: Int, default: UIFont) -> (items: [String], isSuccess: Bool) {
        let items = content.split(separator: "_")
        guard let sizeStr = items.z[safe: index],
            let size = Double(sizeStr.replacingOccurrences(of: "P", with: ".")), size > 0,
            let fontName = items.z[safe: index + 1], !fontName.isEmpty
            else {
                return ([content], false)
        }
        if let weight = items.z[safe: index + 2], !weight.isEmpty {
            return ([size.description, fontName.appending("-").appending(weight.capitalized)], true)
        } else {
            return ([size.description, String(fontName)], true)
        }
    }
    
    static public func parserTheme<K, R>(from json: [String: Any], for manager: ZThemeManager<K, R>, typeKey: String = "type", defaultValueKey: String = "default", valuesKey: String = "values") {
        manager.currentTheme = json[typeKey] as? Int ?? 0
        if let `default` = json[defaultValueKey] as? K {
            manager.defaultValue = manager.item(for: `default`, rawValue: String(describing: `default`))
        }
        manager.itemMap = json[valuesKey] as? [K: [String]] ?? [:]
    }

    static public func getJSONObject(from bundle: Bundle, file: String, fileType: String) -> [String: Any]? {
        if let url = bundle.url(forResource: file, withExtension: fileType) {
            do {
                let data = try Data(contentsOf: url)
                let jsonObject =  try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                return jsonObject as? [String: Any]
            } catch let error as NSError {
                NSLog("failed to get data or jsonObject: \(#function) \(error)")
            }
        }
        return nil
    }
}

public final class AutoFunctionThemeManager<K: Hashable, R: ZThemeParser>: ZThemeManager<K, R> {
    public var defaultKeyIndex = 1
    public var autoAssertEnabled = true
    public override var itemMap: [K : [String]] {
        didSet {
            if autoAssertEnabled {
                autoAssertTheme()
            }
        }
    }
    
    override public func item(for key: K? = nil, indexInOtherTheme: [Int] = [], rawValue: String = #function) -> R.ThemeType {
        let rawValue = String(rawValue.prefix(upTo: rawValue.index(of: "(") ?? rawValue.endIndex))
        var realKey = key
        if realKey == nil, let rawKey = rawValue.split(separator: "_").z[safe: defaultKeyIndex] {
            realKey = (String(rawKey) as? K) ?? (Int(rawKey) as? K)
        }
        if let key = realKey {
            return super.item(for: key, indexInOtherTheme: indexInOtherTheme, rawValue: rawValue)
        }
        return R.create(from: parser(rawValue, indexInRawValue, defaultValue), default: defaultValue)
    }
    
    final public func autoAssertTheme() {
        itemMap.forEach { (data) in
            for (index, value) in data.value.enumerated() {
                if let rawValue = value.split(separator: "_").z[safe: indexInItem] {
                    if item(for: data.key, rawValue: String(rawValue)) == defaultValue {
                        assert(false, "error rawValue \(value) at \(index) for key \(data.key)")
                    }
                } else {
                    assert(false, "nil rawValue at \(index) for key \(data.key)")
                }
            }
        }
    }
}

extension UIColor: ZThemeParser {
    public typealias ThemeType = UIColor
    
    public static func create(from data: (items: [String], isSuccess: Bool), default: ThemeType) -> UIColor {
        if data.isSuccess, let item = data.items.first {
            return UIColor(hexStr: item)
        }
        return `default`
    }
}

extension UIFont: ZThemeParser {
    public typealias ThemeType = UIFont
    
    public static func create(from data: (items: [String], isSuccess: Bool), default: ThemeType) -> UIFont {
        if data.isSuccess, let sizeStr = data.items.z[safe: 0], let size = Double(sizeStr), let fontName = data.items.z[safe: 1], let font = UIFont(name: fontName, size: CGFloat(size)) {
            return font
        }
        return `default`
    }
}
