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
    

    public func fetch(productCode : [String], completion: @escaping ([IAPProduct]) -> Void) {
        Task {
            let product = try await IAPProtocol.fetch(productCode : productCode)
            completion(product)
        }
    }
    
    public func purchase(productCode : String) {
        Task {
            let res = await IAPProtocol.purchase(productCode: productCode)
            print("purchase res ---", res)
        }
    }
    
}

