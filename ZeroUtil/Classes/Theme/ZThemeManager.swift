//
//  ZThemeManager.swift
//  Pods
//
//  Created by lyp on 2020/4/14.
//  Copyright © 2020 lyp@zurp.date. All rights reserved.
//

import Foundation

public protocol ZThemeParser: NSObjectProtocol {
    associatedtype ThemeType: Equatable
    
    static func create(from data: (items: [String], isSuccess: Bool), default: ThemeType) -> ThemeType
}

open class ZThemeManager<K: Hashable, R: ZThemeParser>: NSObject {
    public var itemMap = [K: [String]]()
    public var currentTheme: Int = 0 {
        didSet { indexInOther = max(currentTheme - 1, 0) }
    }
    public var parser: (String, Int, R.ThemeType) -> (items: [String], isSuccess: Bool) = { (content, index, _) in
        let items = content.split(separator: "_")
        if index < items.count {
            return (items.suffix(from: index).map({ String($0) }), true)
        }
        return ([content], false)
    }
    public var defaultValue: R.ThemeType
    public var defaultIndexInOther = 0
    public var indexInRawValue = 2, indexInItem = 0
    
    public private(set) var indexInOther = -1
    
    required public init(default: R.ThemeType) {
        self.defaultValue = `default`
        super.init()
    }
    
    open func item(for key: K, indexInOtherTheme: [Int] = [], rawValue: String = #function) -> R.ThemeType {
        if let items = itemMap[key], let item = items.z[safe: indexInOtherTheme.z[safe: indexInOther] ?? defaultIndexInOther] {
            return R.create(from: parser(item, indexInItem, defaultValue), default: defaultValue)
        }
        return R.create(from: parser(rawValue, indexInRawValue, defaultValue), default: defaultValue)
    }    
}
