//
//  IAPProtocol.swift
//  Pods
//
//  Created by 조선비즈PSY on 6/18/25.
//

protocol IAPProtocol {
    func set()
    func fetch(productCode: [String]) async throws -> [CommonProduct]
}

public struct CommonProduct {
    public let id: String
    public let title: String
    public let description: String
    public let price: String
}
