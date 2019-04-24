//
//  TPOSRequest.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 30.01.19.
//  Copyright © 2019 Tillhub. All rights reserved.
//

import Foundation

/// Possible request types for the Tillhub application
///
/// - loadCart: load a cart by cart- or cart-reference-payload, cashier checks out manually
/// - checkoutCart: load a cart by cart- or cart-reference-payload, check out automatically (manual or automatic payments via cart properties)
public enum TPOSRequestType: String, Codable {
    case loadCart = "load_cart"
    case checkoutCart = "checkout_cart"
}

/// A request to the Tillhub application (executed via deep-linking locally)
public struct TPOSRequest<T: Codable>: Codable {
    
    /// Describes general behavior and properties (e.g. account, callback etc.)
    public var header: TPOSRequestHeader
    
    /// Dynamic payload (currently a stand-alone-cart or a reference to a cart within the Tillhub environment)
    public var payload: T
}

/// Mandatory header for a TillhubPointOfSaleSDK request
public struct TPOSRequestHeader: Codable {
    
    /// The SDK version will be filled automatically by getting it from the pod's bundle
    public let sdkVersion: String
    
    /// The Tillhub user account UUID, mandatory
    public let clientID: String
    
    /// One of the available TillhubPointOfSaleSDK request types (e.g. loadCart or checkoutCart), madatory
    public let type: TPOSRequestType
    
    /// If present, the TillhubPointOfSaleSDK result will contain this for reference
    public let identifier: String?
    
    /// If present, the Tillhub application will send the response there, appending a TillhubPointOfSaleSDK result object
    public let callbackUrl: URL?
    
    /// If true the Tillhub application will send results to the callback URL
    /// after finishing the intended process without manual triggers from the cashier
    public let autoReturn: Bool?
    
    /// An optional note that can be used for any kind of display
    public let comment: String?
    
    /// The designated initializer for a TillhubPointOfSaleSDK request-header
    ///
    /// - Parameters:
    ///   - clientID: The Tillhub user account UUID, mandatory
    ///   - type: One of the available TillhubPointOfSaleSDK request types (e.g. loadCart or checkoutCart), madatory
    ///   - identifier: If present, the TillhubPointOfSaleSDK result will contain this for reference
    ///   - callbackUrl: If present, the Tillhub application will send the response there, appending a TillhubPointOfSaleSDK result object
    ///   - autoReturn: If a cashier action is needed to trigger a response
    ///   - comment: An optional note that can be used for any kind of display
    public init(clientID: String,
                type: TPOSRequestType,
                identifier: String? = nil,
                callbackUrl: URL? = nil,
                autoReturn: Bool? = false,
                comment: String? = nil) throws {
        self.sdkVersion = TPOSRequestHeader.podVersion
        self.clientID = clientID
        self.type = type
        self.identifier = identifier
        self.callbackUrl = callbackUrl
        self.autoReturn = autoReturn
        self.comment = comment
    }
}

// MARK: - Extension to get the version by the pod
fileprivate extension TPOSRequestHeader {
    private struct Constants {
        static let identifier = "org.cocoapods.TillhubPointOfSaleSDK"
        static let version = "CFBundleShortVersionString"
        static let unspecified = "unspecified"
    }
    static var podVersion: String = {
        return Bundle(identifier: Constants.identifier)?.infoDictionary?[Constants.version] as? String ?? Constants.unspecified
    }()
}
