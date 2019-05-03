//
//  TPOSCartItem.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 24.04.19.
//

import Foundation

/// Various cart item errors
///
/// - productIdInvalid: product UUID validation failed
/// - pricePerUnitNegative: the price per unit is negative
/// - vatRateOutOfRange: vat rate is not within [0.0, 1.0]
public enum TPOSCartItemError: Error {
    case productIdInvalid
    case pricePerUnitNegative
    case vatRateOutOfRange
}

/// Type of a cart item
///
/// - item: The item contains a givven quantity of a sellable product
/// - discount: The item represents an absolute discount within a cart
/// - tip: The item describes tip given by a customer
public enum TPOSCartItemType: String, Codable {
    case item
    case discount
    case tip
}

/// Represents an item/ a position within a cart/potential sale
public struct TPOSCartItem: Codable {
    
    /// Type of the item (e.g. item, discount or tip), mandatory
    public let type: TPOSCartItemType
    
    /// The item's quantity, should not be zero
    public let quantity: Decimal
    
    /// Product UUID within the Tillhub environment, mandatory
    public let productId: String
    
    /// The three letter [ISO currency](https://en.wikipedia.org/wiki/ISO_4217) of this item's price, mandatory
    /// this will be implicitely inherited by all children
    public let currency: String
    
    /// The price of this item per quantity 1.0 (before discounts, before taxes if TPOSCart.taxType == .exclusive), mandatory
    public let pricePerUnit: Decimal
    
    /// The tax rate for this item [0.0, 1.0], mandatory
    public let vatRate: Decimal
    
    /// An arbitrary title for this position (e.g. product name)
    public let title: String?
    
    /// An arbitrary note for this position (e.g. product detail description)
    public let comment: String?
    
    /// If present, this describes the salesperson for this item (e.g. for commission)
    public let salesPerson: TPOSStaff?
    
    /// All discounts applied to this specific item
    public let discounts: [TPOSCartItemDiscount]?

    /// Designated initializer for a cart item within a TPOSCart
    ///
    /// - Parameters:
    ///   - type: Type of the item (e.g. item, discount or tip), mandatory
    ///   - quantity: The item's quantity, should not be zero
    ///   - productId: Product UUID within the Tillhub environment, mandatory
    ///   - pricePerUnit: The price of this item per quantity 1.0 (before discounts, before taxes if TPOSCart.taxType == .exclusive), mandatory
    ///   - vatRate: The tax rate for this item, mandatory
    ///   - title: An arbitrary title for this position (e.g. product name)
    ///   - comment: An arbitrary note for this position (e.g. product detail description)
    ///   - salesPerson: If present, this describes the salesperson for this item (e.g. for commission)
    ///   - discounts: All discounts applied to this specific item
    /// - Throws: currency checks, range violation errors for pricePerUnit and vatRate, validation errors for productId
    public init(type: TPOSCartItemType = .item,
                quantity: Decimal = 1.0,
                productId: String,
                currency: String,
                pricePerUnit: Decimal,
                vatRate: Decimal,
                title: String? = nil,
                comment: String? = nil,
                salesPerson: TPOSStaff? = nil,
                discounts: [TPOSCartItemDiscount]? = nil) throws {
        guard UUID(uuidString: productId) != nil else { throw TPOSCartItemError.productIdInvalid }
        guard Locale.isoCurrencyCodes.contains(currency) else { throw TPOSPayloadError.currencyIsoCodeNotFound }
        guard 0.0 <= pricePerUnit else { throw TPOSCartItemError.pricePerUnitNegative }
        guard 0.0 <= vatRate, vatRate <= 1.0 else { throw TPOSCartItemError.vatRateOutOfRange }
        self.currency = currency
        self.type = type
        self.quantity = quantity
        self.productId = productId
        self.pricePerUnit = pricePerUnit
        self.vatRate = vatRate
        self.title = title
        self.comment = comment
        self.salesPerson = salesPerson
        self.discounts = discounts
    }
}
