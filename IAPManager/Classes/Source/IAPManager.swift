//
//  IAPManager.swift
//  IAPManager
//
//  Created by 조선비즈PSY on 6/17/25.
//

import StoreKit

public final class IAPManager: NSObject {
    public static let shared = IAPManager()
    
    private let useStoreKit2 : Bool
    
    private override init() {
        // StoreKit2는 iOS 15 이상
        if #available(iOS 15.0, *) {
            useStoreKit2 = true
        } else {
            useStoreKit2 = false
            SKPaymentQueue.default().add(IAPStoreKit1.shared)
        }
    }
    
    public func set() {
        if #available(iOS 15.0, *) {
            IAPStorekit2.shared.set()
        } else {
            SKPaymentQueue.default().add(IAPStoreKit1.shared)
        }
    }
    
    deinit {
        SKPaymentQueue.default().remove(IAPStoreKit1.shared)
    }
    
}


