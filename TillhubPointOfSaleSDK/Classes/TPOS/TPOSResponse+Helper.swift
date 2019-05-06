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



/// General errors regarding a TillhubPointOfSaleSDK response
///
/// - encodingError: response could not be encoded (to JSON)
/// - urlEncodingError: response JSON could not be encoded (to URL)
/// - decodingError: response could not be decoded (from JSON)
/// - urlDecodingError: response JSON could not be decoded (from URL)
public enum TPOSResponseError: Error {
    case encodingError
    case urlEncodingError
    case decodingError
    case urlDecodingError
}

// MARK: - Extensions for serialization (used by Tillhub)
extension TPOSResponse {
    
    /// Creates a deep link URL from a TPOSResponse, pod-private
    /// - only the query items are added to the TPOSRequest.header.callbackUrl
    ///
    /// - Returns: deep link URL to call from the Tillhub application
    /// - Throws: encoding errors (JSON, URL)
    func url() throws -> URL {
        let data = try JSONEncoder().encode(self)
        guard let json = String(data: data, encoding: .utf8) else {
            throw TPOSResponseError.encodingError
        }

        var components = URLComponents()
        components.scheme = header.urlScheme
        components.host = TPOS.host
        components.path = "/\(header.requestActionPath.rawValue)/\(header.requestPayloadType.rawValue)"
        
        let queryItem = URLQueryItem(name: TPOS.Url.responseQuery,
                                     value: json.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
        if components.queryItems?.isEmpty == false {
            components.queryItems?.append(queryItem)
        } else {
            components.queryItems = [queryItem]
        }
        guard let url = components.url else { throw TPOSResponseError.urlEncodingError }
        
        return url
    }
}

// MARK: - Extensions for de-serialization (can be used by external applications)
extension TPOSResponse {
    /// Initializer from existing URL
    ///
    /// - Parameter url: a deep link URL according to TillhubPointOfSaleSDK
    /// - Throws: decoding errors (URL, JSON)
    public init(url: URL) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            components.host == TPOS.host else {
             throw TPOSError.versionMismatch
        }
        guard let json = components.queryItems?.filter({ $0.name == TPOS.Url.responseQuery }).first?.value?.removingPercentEncoding else {
                throw TPOSResponseError.urlDecodingError
        }
        guard let data = json.data(using: .utf8) else { throw TPOSResponseError.decodingError }
        self = try JSONDecoder().decode(TPOSResponse.self, from: data)
    }
}
