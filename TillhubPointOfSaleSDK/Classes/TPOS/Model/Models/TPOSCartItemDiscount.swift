//
//  TPOSCartItemDiscount.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 24.04.19.
//

import Foundation

/// Various discount errors
///
/// - absoluteValueNegative: discount value was negative
/// - relativeValueOutOfRange: discount value is not in [0.0, 1.0]
public enum TPOSCartItemDiscountError: Error {
    case absoluteValueNegative
    case relativeValueOutOfRange
}

/// The type of a discount, defines the meaning of TPOSCartItemDiscount.value
///
/// - absolute: The discount represents an absolute monetary value
/// - relative: The discount will be calculated relatively to TPOSCartItem's value
public enum TPOSCartItemDiscountType: String, Codable {
    case absolute
    case relative
}

/// Discount representation inside a TPOSCartItem
public struct TPOSCartItemDiscount: Codable {
    
    /// Type of the discount (absolute or relative)
    public let type: TPOSCartItemDiscountType
    
    /// The value of the discount:
    /// If type is 'absolute', value will represent an absolute monetary value >= 0.0
    /// If type is 'relative', value will represent a rate [0.0, 1.0]
    public let value: Decimal
    
    /// An arbitrary note for the discount (e.g. name or reason)
    public let comment: String?
    
    /// Designated initializer for discount
    ///
    /// - Parameters:
    ///   - type: Type of the discount (absolute or relative)
    ///   - value: The value of the discount (>= 0.0 for absolute value, [0.0, 1.0] for rate)
    ///   - comment: An arbitrary note for the discount (e.g. name or reason)
    /// - Throws: throws range violation errors for value
    public init(type: TPOSCartItemDiscountType,
                value: Decimal,
                comment: String? = nil) throws {
        switch type {
        case .absolute:
            guard 0.0 <= value else { throw TPOSCartItemDiscountError.absoluteValueNegative }
        case .relative:
            guard 0.0 <= value, value <= 1.0 else { throw TPOSCartItemDiscountError.relativeValueOutOfRange }
        }
        self.type = type
        self.comment = comment
        self.value = value
    }
}
