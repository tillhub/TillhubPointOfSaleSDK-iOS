//
//  TPOSTransaction.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 29.04.19.
//

import Foundation

/// Response object for a successful transaction
public struct TPOSTransaction: Codable {
    
    /// The unique transaction ID within the Tillhub environment,
    /// in case the transaction is not yet synchronized this will be nil
    public let transactionId: String?
    
    /// The client transaction ID within the Tillhub environment,
    /// this will always be set by the Tillhub application itself
    public let clientTransactionId: String
    
    /// Items/positions of this transaction
    public let items: [TPOSCartItem]
    
    /// Payments of this transaction
    public let payments: [TPOSPayment]
    
    /// Monetary summary information about this transaction
    public let summary: TPOSTransactionSummary?

    /// An arbitrary title that can be saved alongside a transaction
    public let title: String?
    
    /// An arbitrary text that can be saved alongside a transaction
    public let comment: String?
    
    /// Customer of this transaction
    public let customer: TPOSCustomer?
    
    /// Cashier/operator of the POS
    public let cashier: TPOSStaff?

    /// Designated initializer of a transaction for a TillhubPointOfSaleSDK response
    ///
    /// - Parameters:
    ///   - transactionId: The unique transaction ID within the Tillhub environment
    ///   - clientTransactionId: The client transaction ID within the Tillhub environment
    ///   - currency: The three letter [ISO currency](https://en.wikipedia.org/wiki/ISO_4217) of this transaction
    ///   - items: Items/positions of this transaction
    ///   - payments: Payments of this transaction
    ///   - summary: Monetary summary information about this transaction
    ///   - title: An arbitrary title that can be saved alongside a transaction
    ///   - comment: An arbitrary text that can be saved alongside a transaction
    ///   - customer: Customer of this transaction
    ///   - cashier: Cashier/operator of the POS
    /// - Throws: throws errors on currency check
    public init(transactionId: String?,
                clientTransactionId: String,
                currency: String,
                taxType: TPOSTaxType,
                items: [TPOSCartItem] = [],
                payments: [TPOSPayment] = [],
                summary: TPOSTransactionSummary? = nil,
                title: String? = nil,
                comment: String? = nil,
                customer: TPOSCustomer? = nil,
                cashier: TPOSStaff? = nil) throws {
        guard Locale.isoCurrencyCodes.contains(currency) else { throw TPOSError.currencyIsoCodeNotFound }
        self.transactionId = transactionId
        self.clientTransactionId = clientTransactionId
        self.items = items
        self.payments = payments
        self.summary = summary
        self.title = title
        self.comment = comment
        self.customer = customer
        self.cashier = cashier
    }
}
