//
//  ZString+Extension.swift
//  Pods
//
//  Created by lyp on 2020/4/3.
//  Copyright © 2020 lyp@zurp.date. All rights reserved.
//

import Foundation

public extension String {
    var z: ZString { return ZString(target: self) }
}

open class ZString: NSObject {
    public let target: String
    
    public init(target: String) {
        self.target = target
    }
    
    open func isSimpleFileName(isMultiPath: Bool = false) -> Bool {
        for item in [target.first?.lowercased(), target.last?.lowercased()] {
            if let item = item, !((item >= "a" && item <= "z") || (item >= "0" && item <= "9")) {
                return false
            }
        }
        return target.allSatisfy { (char) -> Bool in
            if char.lowercased() >= "a", char.lowercased() <= "z" {
                return true
            }
            if char >= "0", char <= "9" {
                return true
            }
            if char == "-" || char == "_" || (isMultiPath && char == "/") {
                return true
            }
            return false
        }
    }
}
