//
//  TPOSTypes.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 23.04.19.
//

import Foundation


/// Scheme for applying taxes
///
/// - inclusive: taxes are already included in the item price (e.g. EU)
/// - exclusive: taxes will be added on top of the item price (e.g. US)
public enum TPOSTaxType: String, Codable {
    case inclusive
    case exclusive
}

/// Customer (per cart)
public struct TPOSCustomer: Codable {
    
    /// A displayable name
    public var name: String?
    
    /// An internal reference (e.g. customer number or Tillhub customer ID)
    public var customId: String?
    
    public init() {}
}

/// Staff (cashier per cart / salesperson per item)
public struct TPOSStaff: Codable {
    
    /// A displayable name
    public var name: String?
    
    /// An internal reference (e.g. staff number or Tillhub staff ID)
    public var customId: String?
    
    public init() {}
}
