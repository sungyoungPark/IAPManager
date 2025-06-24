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
    
    public func purchase(productCode : String, onPurchaseSuccess: ((Result<[String:Any], Error>) -> Void)? = nil) {
        Task {
            do {
                let result = try await IAPProtocol.purchase(productCode: productCode)
                
                switch result {
                case .success(let receipt) :
                    if let receipt = receipt as? SKPaymentTransaction { //storekit1
                        let purchaseResult = self.dictionary(from: receipt)
                        onPurchaseSuccess?(.success(purchaseResult))
                    }
                    else if #available(iOS 15.0, *) {
                        if let receipt = receipt as? Transaction {
                            let purchaseResult = self.dictionary(from: receipt)
                            onPurchaseSuccess?(.success(purchaseResult))
                        }
                    }
                  
                default :
                    break
    
                }
                
                
            }catch {
                
            }
            
        }
    }
    
}

extension IAPManager {
    
    private func dictionary(from transaction: SKPaymentTransaction) -> [String: Any] {
        var dict: [String: Any] = [:]
        
        dict["productIdentifier"] = transaction.payment.productIdentifier
        dict["transactionIdentifier"] = transaction.transactionIdentifier ?? ""
        dict["transactionDate"] = transaction.transactionDate ?? Date()
        dict["originalTransactionIdentifier"] = transaction.original?.transactionIdentifier ?? ""
        dict["transactionState"] = transaction.transactionState.rawValue
        
        return dict
    }
    
    
    @available(iOS 15.0, *)
    private func dictionary(from transaction: Transaction) -> [String: Any] {
        var dict: [String: Any] = [:]
        
        dict["productID"] = transaction.productID
        dict["transactionID"] = transaction.id
        dict["purchaseDate"] = transaction.purchaseDate
        dict["originalTransactionID"] = transaction.originalID
        dict["ownershipType"] = transaction.ownershipType.rawValue
        dict["isUpgraded"] = transaction.isUpgraded
        dict["revocationDate"] = transaction.revocationDate as Any
        dict["appAccountToken"] = transaction.appAccountToken?.uuidString ?? ""
        dict["signedDate"] = transaction.signedDate
        dict["jsonRepresentation"] = transaction.jsonRepresentation

        return dict
    }
    
}
