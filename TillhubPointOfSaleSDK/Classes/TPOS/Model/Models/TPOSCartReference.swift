//
//  TPOSCartReference.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 04.02.19.
//

import Foundation

/// Various cart reference errors
///
/// - cartIdInvalid: cart id is not a valid UUID
/// - branchIdInvalid: branch id is not a valid UUID
public enum TPOSCartReferenceError: Error {
    case cartIdInvalid
    case branchIdInvalid
}

/// Description of a cart created with the Tillhub Carts API
public struct TPOSCartReference: Codable {
    
    /// The UUID of that cart object within the Tillhub environment
    public var cartId: String
    
    /// The Tillhub branch where this cart was created and is valid, optional
    public let branchId: String?
    
    /// Optional payment intent
    public let paymentIntent: TPOSPaymentIntent?
    
    /// Designated initializer for a cart reference
    ///
    /// - Parameters:
    ///   - cartId: The UUID of that cart object within the Tillhub API
    ///   - branchId: The Tillhub branch where this cart was created and is valid
    ///   - paymentIntent: Optional payment intent
    /// - Throws: validation errors for cartId and branchId (if present)
    public init(cartId: String,
                branchId: String? = nil,
                paymentIntent: TPOSPaymentIntent? = nil) throws {
        guard UUID(uuidString: cartId) != nil else { throw TPOSCartReferenceError.cartIdInvalid }
        if let branchId = branchId {
            guard UUID(uuidString: branchId) != nil else { throw TPOSCartReferenceError.branchIdInvalid }
        }
        self.cartId = cartId
        self.branchId = branchId
        self.paymentIntent = paymentIntent
    }
}
