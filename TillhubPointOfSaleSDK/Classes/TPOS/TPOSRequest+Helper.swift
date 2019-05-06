//
//  TPOSRequest+Helper.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 30.01.19.
//  Copyright © 2019 Tillhub. All rights reserved.
//

import Foundation


///
/// - encodingError: request could not be JSON encoded
/// - urlError: URL construction with JSON data failed



/// General errors regarding a TillhubPointOfSaleSDK request
///
/// - hostDecodingMismatch: host component must be TillhubPointOfSaleSDK always
/// - payloadTypeDecoding: payload type could not be inferred from a URL
/// - actionPathDecoding: action path could not be inferred from a URL
/// - encodingError: request could not be encoded (to JSON)
/// - urlEncodingError: request JSON could not be encoded (to URL)
/// - decodingError: request could not be decoded (from JSON)
/// - urlDecodingError: request JSON could not be decoded (from URL)
public enum TPOSRequestError: Error {
    case payloadTypeDecoding
    case actionPathDecoding
    case encodingError
    case urlEncodingError
    case decodingError
    case urlDecodingError
}

// MARK: - Extensions for serialization (used by external applications)
extension TPOSRequest {

    /// Creates a deep link URL from a TPOSRequest, pod-private
    ///
    /// - Parameter scheme: target scheme for Tillhub application
    /// - Returns: deep link URL to call the Tillhub application
    /// - Throws: encoding errors (JSON, URL)
    func url(_ scheme: String) throws -> URL {
        let data = try JSONEncoder().encode(self)
        guard let json = String(data: data, encoding: .utf8) else {
            throw TPOSRequestError.encodingError
        }
        var components = URLComponents()
        components.scheme = scheme
        components.host = TPOS.host
        components.path = "/\(header.actionPath.rawValue)/\(header.payloadType.rawValue)"
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
        components.host == TPOS.host else {
            throw TPOSError.versionMismatch
        }
        guard let json = components.queryItems?.filter({ $0.name == TPOS.Url.requestQuery }).first?.value?.removingPercentEncoding else {
                throw TPOSRequestError.urlDecodingError
        }
        guard let data = json.data(using: .utf8) else { throw TPOSRequestError.decodingError }
        self = try JSONDecoder().decode(TPOSRequest.self, from: data)
    }
}
