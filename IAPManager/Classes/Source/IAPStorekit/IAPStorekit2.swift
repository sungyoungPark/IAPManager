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
    
    private var iapProducts : [String : Product] = [:]
    
    func set() {
        updateListenerTask = listenForTransactions()
    }
    
    func fetch(productCode: [String]) async throws -> [IAPProduct] {
        let products = try await Product.products(for: productCode)
        
        return products.map { [weak self] in
            self?.iapProducts[$0.id] = $0
            return IAPProduct(
                id: $0.id,
                title: $0.displayName,
                description: $0.description,
                price: $0.displayPrice
            )
        }
    }
    
    func purchase(productCode: String) async -> IAPPurchaseResult {
        print("storekit2", productCode)
        
        if let iapProduct = iapProducts[productCode] {
            if iapProduct.id == productCode {
                do {
                    return try await handlePurchase(product: iapProduct)
                }
                catch {
                    return .unknown(error)
                }
            }
            return .failure(.productNotFound)
        }
        else { //구매 내역 없음
            do {
                let _ = try await fetch(productCode: [productCode])
                guard let iapProduct = iapProducts[productCode] else { return .failure(.productNotFound)}
                if iapProduct.id == productCode {
                    do {
                        return try await handlePurchase(product: iapProduct)
                    }
                    catch {
                        return .unknown(error)
                    }
                }
                return .failure(.productNotFound)
            }
            catch {
                return .unknown(error)
            }
        }
    }
    
    func restore() async throws -> IAPPurchaseResult {
        return .holdPurcahse
    }
    
}

@available(iOS 15.0, *)
extension IAPStorekit2 {
    private func handlePurchase(product : Product) async throws -> IAPPurchaseResult{
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                   
                    await transaction.finish()
                    return .success(transaction)
                case .unverified(_, let error):
                    print("구매 인증 실패: \(error)")
                    return .unknown(error)
                }
            case .userCancelled:
                print("사용자 취소")
                return .failure(.userCancelled)
            case .pending:
                print("보류 중")
                return .holdPurcahse
            @unknown default:
                return .failure(.unknown)
                break
            }
        } catch {
            print("구매 실패: \(error)")
            return .unknown(error)
        }
    }
}
