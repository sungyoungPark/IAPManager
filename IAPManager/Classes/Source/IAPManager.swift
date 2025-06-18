//
//  IAPManager.swift
//  IAPManager
//
//  Created by 조선비즈PSY on 6/17/25.
//

import StoreKit

public final class IAPManager: NSObject {
    public static let shared = IAPManager()
    
    private var memberShipRequest : SKProductsRequest?
    private var membershipProduct : SKProduct?
    
    public func start() {
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
}

extension IAPManager {
    
    public func loadProduct(productCode : [String]) {
        memberShipRequest = SKProductsRequest(productIdentifiers: Set(productCode))
        //memberShipRequest = SKProductsRequest(productIdentifiers: Set(["member_1month_test2"]))

        memberShipRequest?.delegate = self
        memberShipRequest?.start()
    }
    
    
}

extension IAPManager: SKProductsRequestDelegate, SKPaymentTransactionObserver, SKRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("## IAP didReceiveResponse - 상품 상세정보 가져옴!! === \(response.debugDescription)")
        
        for item in response.products {
            
            let product = item
            
            if product.productIdentifier.contains("mem") {
                //membershipProduct = product
                SKPaymentQueue.default().add(SKPayment(product: product))
            }
            
            
            
        }
        
        
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        print("## updatedTransactions - transactions count:\(transactions.count)")
        
        for transaction in transactions {
            
            switch transaction.transactionState {
            case   .purchased:
                
                switch transaction.payment.productIdentifier {
                case let productId where productId.contains("mem"):
                    
                    
                    SKPaymentQueue.default().finishTransaction(transaction)
                    break
                default:
                    print("기타 결제")
                    break
                }
                break
                
                
            case .purchasing:
                break
            case .failed:
                break
            case .restored:
                break
            case .deferred:
                break
            }
            
        }
        
    }
    
}


