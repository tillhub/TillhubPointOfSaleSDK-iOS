//
//  TPOSCart.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 04.02.19.
//

import Foundation

/// Various cart errors
///
/// - currencyIsoCode: discount value was negative
/// - relativeValueOutOfRange: discount value is not in [0.0, 1.0]
public enum TPOSCartError: Error {
    case currencyIsoCodeLengthViolation
}

/// Payload object for a cart (Sale template)
public struct TPOSCart: Codable {
    
    /// The three letter [ISO currency](https://en.wikipedia.org/wiki/ISO_4217) of this sale, mandatory
    /// this will be implicitely inherited by all children
    public let currency: String
    
    /// Tax scheme for the intended sale (mandatory, defaults to EU-style tax-inclusive)
    public let taxType: TPOSTaxType
    
    /// Items/positions for the intended sale (contains product, price, quantity etc.)
    public let items: [TPOSCartItem]
    
    /// Optional payment intent
    public let paymentIntent: TPOSPaymentIntent?
    
    /// An external reference that can be saved alongside a sale and its payments
    public let customId: String?
    
    /// An arbitrary title that can be saved alongside a sale
    public let title: String?
    
    /// An arbitrary text that can be saved alongside a sale
    public let comment: String?
    
    /// Customer of this cart
    public let customer: TPOSCustomer?
    
    /// Cashier/operator of the POS
    public let cashier: TPOSStaff?
    
    // MARK: - Public initializer
    
    /// Designated initializer of a cart for a TillhubPointOfSaleSDK-cart checkout request
    ///
    /// - Parameters:
    ///   - currency: The three letter [ISO currency](https://en.wikipedia.org/wiki/ISO_4217) of this sale, mandatory
    ///   - taxType: Tax scheme for the intended sale (mandatory, defaults to EU-style tax-inclusive)
    ///   - items: Items/positions for the intended sale (contains product, price, quantity etc.)
    ///   - customId: An external reference that can be saved alongside a sale and its payments
    ///   - name: An arbitrary name that can be saved alongside a sale
    ///   - comment: An arbitrary description that can be saved alongside a sale
    ///   - customer: Customer of this cart
    ///   - cashier: Cashier/operator of the POS
    /// - Throws: throws errors on currency check
    public init( currency: String,
                 taxType: TPOSTaxType = .inclusive,
                 items: [TPOSCartItem] = [],
                 paymentIntent: TPOSPaymentIntent? = nil,
                 customId: String? = nil,
                 title: String? = nil,
                 comment: String? = nil,
                 customer: TPOSCustomer? = nil,
                 cashier: TPOSStaff? = nil) throws {
        guard currency.count == 3 else { throw TPOSCartError.currencyIsoCodeLengthViolation }
        self.currency = currency
        self.taxType = taxType
        self.items = items
        self.paymentIntent = paymentIntent
        self.customId = customId
        self.title = title
        self.comment = comment
        self.customer = customer
        self.cashier = cashier
    }
}
