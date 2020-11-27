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
public enum TPOSPaymentType: String, Codable {
    case cash
    case card
    case voucher
    case invoice
    case terminalGiftCard
}

/// Payment tender type that can be triggered automatically
///
/// - automaticCash: currently only cash is supported as automatic payment
public enum TPOSPaymentAutomaticType: String, Codable {
    case automaticCash
}

/// Describes the payment intent within a potential sale/cart
public struct TPOSPaymentIntent: Codable {
    
    /// allowed payment options, must not be empty if paymentId is not set
    public let allowedTypes: [TPOSPaymentType]

    /// If true, trigger a payment automatically (if possible)
    public let automaticType: TPOSPaymentAutomaticType?
    
    public init(allowedTypes: [TPOSPaymentType] = [.cash, .card],
                automaticType: TPOSPaymentAutomaticType? = nil) {
        self.allowedTypes = allowedTypes
        self.automaticType = automaticType
    }
}
