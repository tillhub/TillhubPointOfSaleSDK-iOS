//
//  TPOSCart.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 04.02.19.
//

import Foundation

/// Payload object for a cart (Sale template)
public struct TPOSCart: Codable {
    /// An external reference that can be saved alongside a sale and its payments
    public var customId: String?
    /// An arbitrary name that can be saved alongside a sale
    public var name: String?
    /// An arbitrary text that can be saved alongside a sale
    public var description: String?
    /// Customer of this cart
    public var customer: TPOSCustomer?
    /// Cashier/operator of the POS
    public var cashier: TPOSStaff?
    /// Currency for the intended sale (mandatory, defines all financial values)
    public var currency: String
    /// Tax scheme for the intended sale (mandatory, defaults to EU-style tax-inclusive)
    public var taxType: TPOSTaxType
    /// Items/positions for the intended sale (contains product, price, quantity etc.)
    public var items: [TPOSCartItem]
    
    /// Designated initializer of a cart for a TillhubPointOfSaleSDK-cart checkout request
    ///
    /// - Parameters:
    ///   - customId: An external reference that can be saved alongside a sale and its payments
    ///   - name: An arbitrary name that can be saved alongside a sale
    ///   - description: An arbitrary description that can be saved alongside a sale
    ///   - customer: Customer of this cart
    ///   - cashier: Cashier/operator of the POS
    ///   - currency: Currency for the intended sale (mandatory, defines all financial values)
    ///   - taxType: Tax scheme for the intended sale (mandatory, defaults to EU-style tax-inclusive)
    ///   - items: Items/positions for the intended sale (contains product, price, quantity etc.)
    public init(customId: String? = nil,
                name: String? = nil,
                description: String? = nil,
                customer: TPOSCustomer? = nil,
                cashier: TPOSStaff? = nil,
                currency: String,
                taxType: TPOSTaxType = .inclusive,
                items: [TPOSCartItem] = []) {
        self.customId = customId
        self.name = name
        self.description = description
        self.customer = customer
        self.cashier = cashier
        self.currency = currency
        self.taxType = taxType
        self.items = items
    }
}

// MARK: Cart Item

public enum TPOSCartItemType: String, Codable {
    case tip
    case item
    case discount
}

public struct TPOSCartItem: Codable {
    public var type: TPOSCartItemType = .item
    
    public var name: String?
    public var description: String?

    public var qty: Decimal = 1.0
    
    public var salesPerson: TPOSStaff?
    
    public var discounts: [TPOSCartItemDiscount]?
    
    public var vatRate: Decimal?
    
    public var amountUnitNet: Decimal?
    public var amountUnitGross: Decimal?
    
    public var subTotal: Decimal?
    public var discountAmountTotal: Decimal?
    public var taxAmountTotal: Decimal?
    
    public var amountTotalGross: Decimal?
    public var amountTotalNet: Decimal?
}

public struct TPOSCartItemDiscount: Codable {
    public var index: Int?
    public var name: String?
    public var value: Decimal?
    public var rate: Decimal?
    public var amountTotal: Decimal?
    
    public init() {}
}
