//
//  TPOSCartReference.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 04.02.19.
//

import Foundation

/// Description of a cart created with the Tillhub Carts API
public struct TPOSCartReference: Codable {
    
    /// The Tillhub branch where this cart was created and is valid
    public var branch: String?
    
    /// The UUID of that cart object within the Tillhub API
    public var cartId: String
    
    /// Designated initializer for a
    ///
    /// - Parameters:
    ///   - branch: The Tillhub branch where this cart was created and is valid
    ///   - cartId: The UUID of that cart object within the Tillhub API
    public init(branch: String? = nil,
                cartId: String) {
        self.branch = branch
        self.cartId = cartId
    }
}
