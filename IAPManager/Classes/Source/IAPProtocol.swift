//
//  IAPProtocol.swift
//  Pods
//
//  Created by 조선비즈PSY on 6/18/25.
//

protocol IAPProtocol {
    func set()
    func fetch(productCode: [String]) async throws -> [CommonProduct]
    func purchase(productCode: String) async -> IAPPurchaseResult
    
}

public struct CommonProduct {
    public let id: String
    public let title: String
    public let description: String
    public let price: String
}

enum IAPPurchaseResult {
    case success
    case failure(Error?)
}

enum IAPError: Error {
    case productNotFound
    case userCancelled
}
