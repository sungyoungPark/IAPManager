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
    let buttonTitles = ["상품 정보 가져오기", "구매하기", "구매 복원"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
    }
    
    func setupButtons() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // 오토레이아웃
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // 버튼 생성 및 추가
        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.tag = index // 각 버튼을 구분하기 위한 태그 설정
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        let index = sender.tag
        let title = buttonTitles[index]
        print("✅ 버튼 눌림: \(title)")
        
        // 여기서 각 버튼마다 다른 동작 설정 가능
        switch index {
        case 0:
            //상품 정보 가져오기
            IAPManager.shared.fetch(productCode: ["purchase_Subscription"]) { products in
                var showMessage: String = ""
                for product in products {
                    let message = """
                        상품 ID : \(product.id)
                        상품 Title : \(product.title)
                        상품 설명 : \(product.description)
                        상품 가격 : \(product.price)
                        \n
                    """
                    showMessage += message
                }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.showAlert(title: "상품 정보", message: showMessage, in: self)
                }
            }
            
        case 1:
            print("두 번째 구매 버튼")
            IAPManager.shared.purchase(productCode: "purchase_Subscription") {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.showAlert(title: "", message: "구매 성공", in: self)
                }
            }
        case 2:
            print("세 번째 구매 버튼")
        default:
            break
        }
    }
    
    func showAlert(title: String, message: String, in viewController: UIViewController) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))

        viewController.present(alert, animated: true, completion: nil)
    }
    
}

