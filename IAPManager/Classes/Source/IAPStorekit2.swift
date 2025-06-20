//
//  IAPStorekit2.swift
//  IAPManager
//
//  Created by 조선비즈PSY on 6/18/25.
//

import StoreKit

@available(iOS 15.0, *)
internal final class IAPStorekit2: NSObject, IAPProtocol {
    public static let shared = IAPStorekit2()
    
    private var updateListenerTask: Task<Void, Error>? = nil
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    print("update!!! --- \(result)")
                    //let transaction = try self.checkVerified(result)

                    // Deliver products to the user.
                    //await self.updateCustomerProductStatus()

                    // Always finish a transaction.
                    //await transaction.finish()
                } catch {
                    // StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    print("Transaction failed verification.")
                }
            }
        }
    }
    
    
    func set() {
        updateListenerTask = listenForTransactions()
    }
    
    func fetch(productCode: [String]) async throws -> [CommonProduct] {
        let products = try await Product.products(for: productCode)
        
        return products.map {
            CommonProduct(
                id: $0.id,
                title: $0.displayName,
                description: $0.description,
                price: $0.displayPrice
            )
        }
    }
    
    func purchase(productCode: String) async -> IAPPurchaseResult {
        print("storekit2")
        return .success
    }
    
}

@available(iOS 15.0, *)
extension IAPStorekit2 {
    
}
