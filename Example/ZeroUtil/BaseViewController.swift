//
//  BaseViewController.swift
//  ZeroUtil
//
//  Created by lyp on 03/05/2020.
//  Copyright (c) 2020 lyp@zurp.date. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSLog("deinit: \(type(of: self))")
    }
}
