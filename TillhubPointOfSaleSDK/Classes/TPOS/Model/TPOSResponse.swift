//
//  TPOSResponse.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 29.04.19.
//

import Foundation

/// Overall status of a response from within Tillhub
///
/// - success: the requested action was performed successfully
/// - failure: the requested action failed
public enum TPOSResponsStatus: String, Codable {
    case success = "success"
    case failure = "failure"
}

/// A response from the Tillhub application (executed via deep-linking locally)
public struct TPOSResponse: Codable {
    
    /// Describes general response parameters (e.g. account, callback etc.)
    public var header: TPOSResponseHeader
    
    /// Information about the resulting transaction within the Tillhub environment
    public var payload: TPOSTransaction?
    
    /// Designated initializer
    ///
    /// - Parameters:
    ///   - header: Describes general response parameters (e.g. status, url etc.)
    ///   - payload: Information about the resulting transaction within the Tillhub environment
    public init(header: TPOSResponseHeader,
                payload: TPOSTransaction?) {
        self.header = header
        self.payload = payload
    }
}

/// Mandatory header for a TillhubPointOfSaleSDK response
public struct TPOSResponseHeader: Codable {
    
    /// The SDK version will be filled automatically by getting it from the pod's bundle
    public let sdkVersion: String
    
    /// The id of the associated request
    public let requestId: String
    
    /// The callbackUrl of the associated request
    public let url: URL
    
    /// If set, this contains information about errors during the usage of the Tillhub application
    public let status: TPOSResponsStatus
    
    /// An optional note that can be used for any kind of display
    public let localizedErrorDescription: String?

    /// An optional note that can be used for any kind of display
    public let comment: String?
    
    /// The designated initializer for a TillhubPointOfSaleSDK response-header
    ///
    /// - Parameters:
    ///   - requestId: The id of the associated request
    ///   - error: An optional error
    ///   - comment: An optional comment
    public init(requestId: String,
                url: URL,
                error: Error? = nil,
                comment: String? = nil) {
        self.sdkVersion = TPOS.podVersion
        self.requestId = requestId
        self.url = url
        self.status = (error == nil) ? .success : .failure
        self.localizedErrorDescription = error?.localizedDescription
        self.comment = comment
    }
}
