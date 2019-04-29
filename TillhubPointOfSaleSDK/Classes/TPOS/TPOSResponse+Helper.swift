//
//  TPOSResponse+Helper.swift
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
public enum TPOSResponseError: Error {
    case encodingError
    case urlEncodingError
    case decodingError
    case urlDecodingError
}

// MARK: - Extensions for serialization (used by Tillhub)
extension TPOSResponse {
    
    /// Creates a deep link URL from a TPOSResponse
    ///
    /// - Returns: deep link URL to call the Tillhub application
    /// - Throws: encoding errors (JSON, URL)
    public func url() throws -> URL {
        let data = try JSONEncoder().encode(self)
        guard let json = String(data: data, encoding: .utf8) else {
            throw TPOSResponseError.encodingError
        }
        
        var components = URLComponents(url: header.url, resolvingAgainstBaseURL: true)
        let queryItem = URLQueryItem(name: TPOS.Url.responseQuery,
                                     value: json.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
        if components?.queryItems?.isEmpty == false {
            components?.queryItems?.append(queryItem)
        } else {
            components?.queryItems = [queryItem]
        }
        
        guard let url = components?.url else { throw TPOSResponseError.urlEncodingError }
        
        return url
    }
}

// MARK: - Extensions for de-serialization (used by external applications)
extension TPOSResponse {
    /// Initializer from existing URL
    ///
    /// - Parameter url: a deep link URL according to TillhubPointOfSaleSDK
    /// - Throws: decoding errors (URL, JSON)
    public init(url: URL) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let json = components.queryItems?.filter({ $0.name == TPOS.Url.responseQuery }).first?.value?.removingPercentEncoding else {
                throw TPOSResponseError.urlDecodingError
        }
        guard let data = json.data(using: .utf8) else { throw TPOSResponseError.decodingError }
        self = try JSONDecoder().decode(TPOSResponse.self, from: data)
    }
}
