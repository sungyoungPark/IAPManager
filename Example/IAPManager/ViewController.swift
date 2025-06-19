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
        setupButton()
    }

    
    private func setupButton() {
        let button = UIButton(type: .system)
        button.setTitle("구매하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false

        // 액션 연결
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        view.addSubview(button)

        // AutoLayout
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 150),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func buttonTapped() {
        print("✅ 버튼이 눌렸습니다!")
        IAPManager.shared.load(productCode : ["purchase_Subscription"])
     
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

