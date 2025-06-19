//
//  IAPStoreKit1.swift
//  IAPManager
//
//  Created by 조선비즈PSY on 6/18/25.
//

import StoreKit

internal final class IAPStoreKit1: NSObject, IAPProtocol {
    
    public static let shared = IAPStoreKit1()
    
    private var memberShipRequest : SKProductsRequest?
    private var membershipProduct : SKProduct?
    
    internal func set() {
        SKPaymentQueue.default().add(self)
    }
    
    internal func fetch(productCode: [String]) async throws -> [CommonProduct] {
        
        try await withCheckedThrowingContinuation { continuation in
            memberShipRequest = SKProductsRequest(productIdentifiers: Set(productCode))
            let delegate = IAPStoreKit1Delegate { products in
                let result = products.map {
                    CommonProduct(
                        id: $0.productIdentifier,
                        title: $0.localizedTitle,
                        description: $0.localizedDescription,
                        price: Self.format(price: $0.price, locale: $0.priceLocale)
                    )
                }
                continuation.resume(returning: result)
            }
            
            // retain delegate
            objc_setAssociatedObject(memberShipRequest as Any, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            memberShipRequest?.delegate = delegate
            memberShipRequest?.start()
        }
    }
    
    
    private static func format(price: NSDecimalNumber, locale: Locale) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter.string(from: price) ?? "\(price)"
    }
}

extension IAPStoreKit1 : SKPaymentTransactionObserver, SKRequestDelegate {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        print("## updatedTransactions - transactions count:\(transactions.count)")
        
        for transaction in transactions {
            
            switch transaction.transactionState {
            case .purchased:
                
                switch transaction.payment.productIdentifier {
                case let productId where productId.contains("mem"):
                    
                    break
                default:
                    print("기타 결제")
                    break
                }
                print("결제 끝")
                SKPaymentQueue.default().finishTransaction(transaction)
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


internal final class IAPStoreKit1Delegate : NSObject, SKProductsRequestDelegate {
    
    private let completion: ([SKProduct]) -> Void
    
    init(completion: @escaping ([SKProduct]) -> Void) {
        self.completion = completion
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("## IAP didReceiveResponse - 상품 상세정보 가져옴!! === \(response.debugDescription)")
        
        for item in response.products {
            
            let product = item
            
            if product.productIdentifier.contains("mem") {
                //membershipProduct = product
                SKPaymentQueue.default().add(SKPayment(product: product))
            }
            else {
                SKPaymentQueue.default().add(SKPayment(product: product))
            }
            
        }
        
        
    }
}
