//
//  TPOSRequest+Helper.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 30.01.19.
//  Copyright © 2019 Tillhub. All rights reserved.
//

import Foundation

/// Errors regarding a TillhubPointOfSaleSDK request encoding/decoding
///
/// - jsonEncoding: The request object could not be encoded to JSON data
/// - jsonDecoding: The JSON data could not be decoded to a request object
/// - dataEncoding: The request JSON data could not be encoded to JSON string
/// - dataDecoding: The request JSON string could not be decoded to JSON data
/// - urlEncoding: The request JSON string could not be encoded to URL
/// - urlDecoding: The request URL could not be decoded to JSON string
public enum TPOSRequestError: LocalizedError {
    case jsonEncoding(error: Error)
    case jsonDecoding(error: Error)
    case dataEncoding
    case dataDecoding
    case urlEncoding
    case urlDecoding
    
    public var errorDescription: String? {
        switch self {
        case .jsonEncoding(let error):
            return "The request object could not be encoded to JSON data (\(error.localizedDescription))."
        case .jsonDecoding(let error):
            return "The JSON data could not be decoded to a request object (\(error.localizedDescription))."
        case .dataEncoding:
            return "The request JSON data could not be encoded to JSON string."
        case .dataDecoding:
            return "The request JSON string could not be decoded to JSON data."
        case .urlEncoding:
            return "The request JSON string could not be encoded to URL."
        case .urlDecoding:
            return "The request URL could not be decoded to JSON string."
        }
    }
}

// MARK: - Extensions for serialization (used by external applications)
extension TPOSRequest {

    /// Creates a deep link URL from a TPOSRequest, pod-private
    ///
    /// - Parameter scheme: target scheme for Tillhub application
    /// - Returns: deep link URL to call the Tillhub application
    /// - Throws: encoding errors (JSON, URL)
    func url() throws -> URL {
        var data: Data
        do {
            data = try JSONEncoder().encode(self)
        } catch let error {
            throw TPOSRequestError.jsonEncoding(error: error)
        }
        guard let json = String(data: data, encoding: .utf8) else {
            throw TPOSRequestError.dataEncoding
        }
        var components = URLComponents()
        components.scheme = TPOS.Url.requestScheme
        components.host = TPOS.host
        components.path = "/\(header.actionPath.rawValue)/\(header.payloadType.rawValue)"
        components.queryItems = [URLQueryItem(name: TPOS.Url.requestQuery,
                                              value: json.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))]
        guard let url = components.url else { throw TPOSRequestError.urlEncoding }
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
                throw TPOSRequestError.urlDecoding
        }
        guard let data = json.data(using: .utf8) else {
            throw TPOSRequestError.dataDecoding
        }
        do {
            self = try JSONDecoder().decode(TPOSRequest.self, from: data)
        } catch let error {
            throw TPOSRequestError.jsonDecoding(error: error)
        }
    }
}
