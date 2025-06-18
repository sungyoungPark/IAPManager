//
//  ViewController.swift
//  IAPManager
//
//  Created by ios-sungyoungpark on 06/17/2025.
//  Copyright (c) 2025 ios-sungyoungpark. All rights reserved.
//

import UIKit
import IAPManager

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        IAPManager.shared.test123()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

