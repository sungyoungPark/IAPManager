//
//  File.swift
//  IAPManager
//
//  Created by 박성영 on 6/21/25.
//
enum IAPPurchaseResult {
    case success
    case failure(Error?)
}

enum IAPError: Error {
    case productNotFound
    case userCancelled
}
