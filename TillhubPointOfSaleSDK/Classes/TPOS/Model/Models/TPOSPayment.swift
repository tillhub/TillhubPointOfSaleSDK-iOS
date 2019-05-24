//
//  TPOSPayment.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 29.04.19.
//

import Foundation

/// Represents a payment within a successful TPOSTransaction
public struct TPOSPayment: Codable {
    
    /// Type of the payment (e.g. card or cash)
    public let type: TPOSPaymentType
    
    /// The three letter [ISO currency](https://en.wikipedia.org/wiki/ISO_4217) of this transaction
    public let currency: String
    
    /// The total payed amount, including tip
    public let amountTotal: Decimal
    
    /// The tip included
    public let amountTip: Decimal?

    /// Designated initializer for a payment within a TPOSTransaction
    ///
    /// - Parameters:
    ///   - type: Type of the payment (e.g. card or cash)
    ///   - amountTotal: The total payed amount, including tip
    ///   - amountTip: The tip included
    public init(type: TPOSPaymentType,
                currency: String,
                amountTotal: Decimal,
                amountTip: Decimal? = nil ) throws {
        guard Locale.isoCurrencyCodes.contains(currency) else { throw TPOSPayloadError.currencyIsoCodeNotFound }
        self.type = type
        self.currency = currency
        self.amountTotal = amountTotal
        self.amountTip = amountTip
    }
}
