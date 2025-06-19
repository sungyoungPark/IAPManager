//
//  IAPManager.swift
//  IAPManager
//
//  Created by 조선비즈PSY on 6/17/25.
//

import StoreKit

public final class IAPManager: NSObject {
    public static let shared = IAPManager()
    
    private let IAPProtocol : IAPProtocol
    
    private override init() {
       
        if #available(iOS 15.0, *) {
            IAPProtocol = IAPStorekit2.shared
        } else {
            IAPProtocol = IAPStoreKit1.shared
        }
    }
    
    public func set() {
        IAPProtocol.set()
    }
    

    public func load(productCode : [String]) {
        Task {
            let product = try await IAPProtocol.fetch(productCode : productCode)
            print("product ---", product)
            print("iap ---", IAPProtocol)
        }
    }
    
    deinit {
        SKPaymentQueue.default().remove(IAPStoreKit1.shared)
    }
    
}

