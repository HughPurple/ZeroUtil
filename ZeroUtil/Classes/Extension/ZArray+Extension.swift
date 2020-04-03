//
//  ZArray+Extension.swift
//  Pods
//
//  Created by lyp on 2020/4/5.
//  Copyright © 2020 lyp@zurp.date. All rights reserved.
//

import Foundation

public extension Array {
    var z: ZArray<Element> { return ZArray(target: self) }
}

open class ZArray<Element>: NSObject {
    public let target: Array<Element>
    
    public init(target: Array<Element>) {
        self.target = target
    }
    
    public subscript(safe index: Int) -> Element? {
        if 0 <= index, index < target.count {
            return target[index]
        }
        return nil
    }
    
    open func subSequence(start: Int, end: Int) -> Array<Element>? {
        if 0 <= start, start < end, end <= target.count {
            return Array(target[start..<end])
        }
        return nil
    }
}
