//
//  IAPProtocol.swift
//  Pods
//
//  Created by 조선비즈PSY on 6/18/25.
//

protocol IAPProtocol {
    func set()
    func fetch(productCode: [String]) async throws -> [IAPProduct]
    func purchase(productCode: String) async -> IAPPurchaseResult
    
}
