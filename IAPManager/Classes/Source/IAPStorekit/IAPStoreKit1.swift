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
    private var iapProducts : [String: SKProduct] = [:]
    
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
        transactionObserver = IAPStoreKit1TransactionObserver ()
        guard let transactionObserver = transactionObserver else { return }
        SKPaymentQueue.default().add(transactionObserver)
    }
    
    func fetch(productCode: [String]) async throws -> [IAPProduct] {
        try await withCheckedThrowingContinuation { continuation in
            iapRequest = SKProductsRequest(productIdentifiers: Set(productCode))
            let delegate = IAPStoreKit1Delegate { [weak self] products in
                let result = products.map {
                    self?.iapProducts[$0.productIdentifier] = $0
                    return IAPProduct(
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
    
    func purchase(productCode: String) async throws -> IAPPurchaseResult {
    
        if let product = iapProducts[productCode] {
                if product.productIdentifier == productCode {
                    return try await withCheckedThrowingContinuation { continuation in
                        transactionObserver?.continuation = continuation
                        SKPaymentQueue.default().add(SKPayment(product: product))
                    }
            }
            return .failure(.productNotFound)
        }
        else {
            do {
                let fetchProduct = try await fetch(productCode: [productCode])
                print("FetchProduct ---", fetchProduct)
                guard let product = iapProducts[productCode] else { return .failure(.productNotFound)}
                if product.productIdentifier == productCode {
                    return try await withCheckedThrowingContinuation { continuation in
                        transactionObserver?.continuation = continuation
                        SKPaymentQueue.default().add(SKPayment(product: product))
                    }
                }
                return .failure(.productNotFound)
            } catch {
                return .unknown(error)
            }
        }
        
    }
    
    func restore() async throws -> IAPPurchaseResult {
        print("복원 버튼 클릭")
        SKPaymentQueue.default().restoreCompletedTransactions()
        return try await withCheckedThrowingContinuation { continuation in
            transactionObserver?.continuation = continuation
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
    
    var continuation: CheckedContinuation<IAPPurchaseResult, Error>?
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        print("## updatedTransactions - transactions count:\(transactions.count)")
        
        for transaction in transactions {
            
            switch transaction.transactionState {
            case .purchased:
                
                continuation?.resume(returning: .success(transaction))
                continuation = nil
                SKPaymentQueue.default().finishTransaction(transaction)
                break
                
                
            case .purchasing:
                break
            case .failed:
                break
            case .restored:
                print("복원 완료 : \(transaction.payment.productIdentifier)")
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .deferred:
                break
            }
            
        }
        
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("복원 fin")
        
        let restoredTransactions = queue.transactions.filter { $0.transactionState == .restored }
        
        if restoredTransactions.isEmpty {
            // 복원할 항목 없음
            print("복원할 항목이 없습니다.")
        } else {
            // 복원 성공
            print("복원 성공 ----", restoredTransactions.count)
            continuation?.resume(returning: .success(restoredTransactions))
            continuation = nil
        }
        
        
    }
    
    
}
