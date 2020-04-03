//
//  ZUIViewController+Extension.swift
//  Pods
//
//  Created by lyp on 2020/4/14.
//  Copyright © 2020 lyp@zurp.date. All rights reserved.
//

import Foundation

public extension UIViewController {
    @objc var z: ZUIViewController { return ZUIViewController(target: self) }
}

open class ZUIViewController: NSObject {
    public let target: UIViewController
    
    public init(target: UIViewController) {
        self.target = target
    }
    
    open var navBarFrame: CGRect {
        return target.navigationController?.navigationBar.frame ?? .zero
    }
}
