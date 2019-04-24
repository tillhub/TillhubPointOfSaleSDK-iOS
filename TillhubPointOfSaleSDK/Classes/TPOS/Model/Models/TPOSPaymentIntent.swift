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

/// Describes the payment intent within a potential sale/cart
public struct TPOSPaymentIntent: Codable {
    
    /// allowed payment options, must not be empty if paymentId is not set
    public let allowedTypes: [TKPOSPaymentType]
    
    /// A specific payment option within the Tillhub environment, must be set if allowedTypes is empty
    public let paymentId: String?
    
    /// If true, trigger a payment automatically (if possible)
    public let automatic: Bool
    
    public init(allowedTypes: [TKPOSPaymentType] = [.cash, .card],
                paymentId: String? = nil,
                automatic: Bool = false) throws {
        if let paymentId = paymentId {
            guard UUID(uuidString: paymentId) != nil else { throw TPOSPaymentIntentError.paymentIdInvalid }
        } else {
            guard allowedTypes.isEmpty == false else { throw TPOSPaymentIntentError.paymentIdInvalid }
        }
        self.allowedTypes = allowedTypes
        self.paymentId = paymentId
        self.automatic = automatic
    }
}
