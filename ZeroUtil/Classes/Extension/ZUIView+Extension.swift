//
//  ZUIView+Extension.swift
//  Pods
//
//  Created by lyp on 2020/4/10.
//  Copyright © 2020 lyp@zurp.date. All rights reserved.
//

import Foundation

public extension UIView {
    @objc var z: ZUIView { return ZUIView(target: self) }
}

open class ZUIView: NSObject {
    public let target: UIView
    
    public init(target: UIView) {
        self.target = target
    }
    
    open var snapshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(target.frame.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            target.layer.layoutIfNeeded()
            target.layer.render(in: context)
        }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
