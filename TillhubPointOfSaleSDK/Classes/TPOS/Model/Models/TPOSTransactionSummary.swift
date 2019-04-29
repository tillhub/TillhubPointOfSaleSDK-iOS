//
//  TPOSTransactionSummary.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 29.04.19.
//

import Foundation

/// Monetary summary information about a TPOSTransaction
public struct TPOSTransactionSummary: Codable {
    
    /// The total payable amount, including taxes
    public let amountTotalGross: Decimal
    
    /// The total amount excluding taxes
    public let amountTotalNet: Decimal
    
    /// The total value of the transaction before discounts
    /// (and before taxes in case of TPOSTaxType.exclusive)
    public let subTotal: Decimal
    
    /// The total amount of any applied discounts
    public let discountAmountTotal: Decimal
    
    ///The total amount of taxes
    public let taxAmountTotal: Decimal
    
    /// The total amount of tips included in this transaction
    public let tipAmountTotal: Decimal
    
    /// The total amount of all payments (including tips, before change)
    public let paymentAmountTotal: Decimal
    
    /// The total amount of change given back to the customer
    /// paymentAmountTotal - amountTotalGross
    public let changeAmountTotal: Decimal
    
    /// Designated initializer for a transaction summary
    ///
    /// - Parameters:
    ///   - amountTotalGross: The total payable amount, including taxes
    ///   - amountTotalNet: The total amount excluding taxes
    ///   - subTotal: The total value of the transaction before discounts
    ///   - discountAmountTotal: the total amount of any applied discounts
    ///   - taxAmountTotal: the total amount of taxes
    ///   - tipAmountTotal: The total amount of tips included in this transaction
    ///   - paymentAmountTotal: The total amount of all payments (including tips, before change)
    ///   - changeAmountTotal: The total amount of change given back to the customer
    public init( amountTotalGross: Decimal,
                 amountTotalNet: Decimal = 0.0,
                 subTotal: Decimal = 0.0,
                 discountAmountTotal: Decimal = 0.0,
                 taxAmountTotal: Decimal = 0.0,
                 tipAmountTotal: Decimal = 0.0,
                 paymentAmountTotal: Decimal = 0.0,
                 changeAmountTotal: Decimal = 0.0 ) {
        self.amountTotalGross = amountTotalGross
        self.amountTotalNet = amountTotalNet
        self.subTotal = subTotal
        self.discountAmountTotal = discountAmountTotal
        self.taxAmountTotal = taxAmountTotal
        self.tipAmountTotal = tipAmountTotal
        self.paymentAmountTotal = paymentAmountTotal
        self.changeAmountTotal = changeAmountTotal
    }
}
