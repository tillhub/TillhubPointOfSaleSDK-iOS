//
//  TPOSRequest.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 30.01.19.
//  Copyright © 2019 Tillhub. All rights reserved.
//

import Foundation

/// Constraints for request payloads, might
public protocol TPOSRequestPayload: Codable {}

/// Possible request types for the Tillhub application
///
/// - load: load a cart by cart- or cart-reference-payload, cashier checks out manually
/// - checkout: load a cart by cart- or cart-reference-payload, check out automatically (manual or automatic payments via cart properties)
public enum TPOSRequestActionPath: String, Codable {
    case load = "/load"
    case checkout = "/checkout"
}

/// Possible payload types for the Tillhub application
///
/// - cart: a full cart object
/// - cartReference: a reference description of a cart within the Tillhub environment
public enum TPOSRequestPayloadType: String, Codable {
    case cart = "cart"
    case cartReference = "cart_reference"
}

/// A request to the Tillhub application (executed via deep-linking locally)
public struct TPOSRequest<T: TPOSRequestPayload>: Codable {
    
    /// Describes general behavior and properties (e.g. account, callback etc.)
    public var header: TPOSRequestHeader
    
    /// Dynamic payload (currently a stand-alone-cart or a reference to a cart within the Tillhub environment)
    public var payload: T
    
    /// Designated initializer
    ///
    /// - Parameters:
    ///   - header: Describes general behavior and properties (e.g. account, callback etc.)
    ///   - payload: Dynamic payload (currently a stand-alone-cart or a reference to a cart within the Tillhub environment)
    public init(header: TPOSRequestHeader,
                payload: T) {
        self.header = header
        self.payload = payload
    }
}

/// Mandatory header for a TillhubPointOfSaleSDK request
public struct TPOSRequestHeader: Codable {
    
    /// The SDK version will be filled automatically by getting it from the pod's bundle
    public let sdkVersion: String
    
    /// The TillhubPointOfSaleSDK result will contain this for reference
    public let requestId: String
    
    /// The Tillhub user account UUID, mandatory
    public let clientID: String
    
    /// One of the available TillhubPointOfSaleSDK request action types (e.g. load or checkout), madatory
    public let actionType: TPOSRequestActionPath
    
    /// One of the available TillhubPointOfSaleSDK request payload types (e.g. cart or cartReference), madatory
    public let payloadType: TPOSRequestPayloadType
    
    /// If present, the TillhubPointOfSaleSDK will mark payments etc. with this reference
    public let customReference: String?
    
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
    ///   - actionType: One of the available TillhubPointOfSaleSDK request types (e.g. loadCart or checkoutCart), madatory
    ///   - customReference: If present, the TillhubPointOfSaleSDK result will contain this for reference
    ///   - callbackUrl: If present, the Tillhub application will send the response there, appending a TillhubPointOfSaleSDK result object
    ///   - autoReturn: If a cashier action is needed to trigger a response
    ///   - comment: An optional note that can be used for any kind of display
    public init(clientID: String,
                actionType: TPOSRequestActionPath,
                payloadType: TPOSRequestPayloadType,
                customReference: String? = nil,
                callbackUrl: URL? = nil,
                autoReturn: Bool? = false,
                comment: String? = nil) {
        self.sdkVersion = TPOS.podVersion
        self.requestId = UUID().uuidString
        self.clientID = clientID
        self.actionType = actionType
        self.payloadType = payloadType
        self.customReference = customReference
        self.callbackUrl = callbackUrl
        self.autoReturn = autoReturn
        self.comment = comment
    }
}
