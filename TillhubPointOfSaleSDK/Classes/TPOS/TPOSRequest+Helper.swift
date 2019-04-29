//
//  TPOSRequest+Helper.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 30.01.19.
//  Copyright © 2019 Tillhub. All rights reserved.
//

import Foundation

/// General errors regarding a TillhubPointOfSaleSDK request
///
/// - encodingError: request could not be JSON encoded
/// - urlError: URL construction with JSON data failed
public enum TPOSRequestError: Error {
    case encodingError
    case urlEncodingError
    case decodingError
    case urlDecodingError
}

// MARK: - Extensions for serialization (used by external applications)
extension TPOSRequest {

    /// Creates a deep link URL from a TPOSRequest
    ///
    /// - Returns: deep link URL to call the Tillhub application
    /// - Throws: encoding errors (JSON, URL)
    public func url() throws -> URL {
        let data = try JSONEncoder().encode(self)
        guard let json = String(data: data, encoding: .utf8) else {
            throw TPOSRequestError.encodingError
        }

        var components = URLComponents()
        components.scheme = TPOS.Url.scheme
        components.host = header.payloadType.rawValue
        components.path = header.actionType.rawValue
        components.queryItems = [URLQueryItem(name: TPOS.Url.requestQuery,
                                              value: json.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))]
        
        guard let url = components.url else { throw TPOSRequestError.urlEncodingError }
        
        return url
    }
}

// MARK: - Extensions for de-serialization (used by Tillhub)
extension TPOSRequest {
    
    /// Initializer from existing URL
    ///
    /// - Parameter url: a deep link URL according to TillhubPointOfSaleSDK
    /// - Throws: decoding errors (URL, JSON)
    public init(url: URL) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            components.scheme == TPOS.Url.scheme,
            let json = components.queryItems?.filter({ $0.name == TPOS.Url.requestQuery }).first?.value?.removingPercentEncoding else {
                throw TPOSRequestError.urlDecodingError
        }
        guard let data = json.data(using: .utf8) else { throw TPOSRequestError.decodingError }
        self = try JSONDecoder().decode(TPOSRequest.self, from: data)
    }
}
