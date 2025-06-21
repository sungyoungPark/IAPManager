//
//  IAPStoreKit1.swift
//  IAPManager
//
//  Created by 조선비즈PSY on 6/18/25.
//

import StoreKit

internal final class IAPStoreKit1: NSObject {
    
    public static let shared = IAPStoreKit1()
    
    private var iapRequest : SKProductsRequest?
    private var iapProducts : [SKProduct]?
    
    private var transactionObserver : IAPStoreKit1TransactionObserver?
    
    private static func format(price: NSDecimalNumber, locale: Locale) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter.string(from: price) ?? "\(price)"
    }
 
    deinit {
        guard let transactionObserver = transactionObserver else { return }
        SKPaymentQueue.default().remove(transactionObserver)
    }
    
}

extension IAPStoreKit1 : IAPProtocol {
    func set() {
        transactionObserver = IAPStoreKit1TransactionObserver { [weak self] result in
            print("res ---", result)
        }
        guard let transactionObserver = transactionObserver else { return }
        SKPaymentQueue.default().add(transactionObserver)
    }
    
    func fetch(productCode: [String]) async throws -> [IAPProduct] {
        try await withCheckedThrowingContinuation { continuation in
            iapRequest = SKProductsRequest(productIdentifiers: Set(productCode))
            let delegate = IAPStoreKit1Delegate { [weak self] products in
                self?.iapProducts = products
                let result = products.map {
                    IAPProduct(
                        id: $0.productIdentifier,
                        title: $0.localizedTitle,
                        description: $0.localizedDescription,
                        price: Self.format(price: $0.price, locale: $0.priceLocale)
                    )
                }
                continuation.resume(returning: result)
            }
            
            // retain delegate
            objc_setAssociatedObject(iapRequest as Any, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            iapRequest?.delegate = delegate
            iapRequest?.start()
        }
    }
    
    func purchase(productCode: String) async -> IAPPurchaseResult {
        print("storekit1")
        
        if let iapProducts = iapProducts {
            for iapProduct in iapProducts {
                if iapProduct.productIdentifier == productCode {
                    SKPaymentQueue.default().add(SKPayment(product: iapProduct))
                    return .success
                }
            }
            return .failure(.productNotFound as IAPError)
        }
        else {
            do {
                let _ = try await fetch(productCode: [productCode])
                guard let iapProducts = iapProducts else { return .failure(.productNotFound as IAPError) }
                for iapProduct in iapProducts {
                    if iapProduct.productIdentifier == productCode {
                        SKPaymentQueue.default().add(SKPayment(product: iapProduct))
                        return .success
                    }
                }
                return .failure(.productNotFound as IAPError)
            } catch {
                return .failure(error)
            }
        }
        
    }
    
    
}


extension IAPStoreKit1 :  SKRequestDelegate {
  

}


internal final class IAPStoreKit1Delegate : NSObject, SKProductsRequestDelegate {
    
    private let completion: ([SKProduct]) -> Void
    
    init(completion: @escaping ([SKProduct]) -> Void) {
        self.completion = completion
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("## IAP didReceiveResponse - 상품 상세정보 가져옴!! === \(response.debugDescription) \(response.products)")
        completion(response.products)
        
    }
}

internal final class IAPStoreKit1TransactionObserver : NSObject, SKPaymentTransactionObserver {
    
    private let completion: (IAPPurchaseResult) -> Void
    
    init(completion: @escaping (IAPPurchaseResult) -> Void) {
        self.completion = completion
    }
    
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
                completion(.success)
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
