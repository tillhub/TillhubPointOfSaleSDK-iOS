//
//  TPOSCartPayment.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 24.04.19.
//

import Foundation

public enum TPOSPaymentIntentError: Error {
    case paymentIdInvalid
    case allowedTypesIsEmpty
    case vatRateOutOfRange
}

/// Payment tender type
///
/// - cash: cash
/// - card: credit or debit cards
/// - voucher: voucher if available
/// - invoice: invoice
public enum TKPOSPaymentType: String, Codable {
    case cash
    case card
    case voucher
    case invoice
}

/// Payment tender type that can be triggered automatically
///
/// - automaticCash: currently only cash is supported as automatic payment
public enum TKPOSPaymentAutomaticType: String, Codable {
    case automaticCash
}

/// Describes the payment intent within a potential sale/cart
public struct TPOSPaymentIntent: Codable {
    
    /// allowed payment options, must not be empty if paymentId is not set
    public let allowedTypes: [TKPOSPaymentType]

    /// If true, trigger a payment automatically (if possible)
    public let automaticType: TKPOSPaymentAutomaticType?
    
    public init(allowedTypes: [TKPOSPaymentType] = [.cash, .card],
                automaticType: TKPOSPaymentAutomaticType? = nil) {
        self.allowedTypes = allowedTypes
        self.automaticType = automaticType
    }
}
