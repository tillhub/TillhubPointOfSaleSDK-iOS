//
//  TPOSResponse+Helper.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 30.01.19.
//  Copyright © 2019 Tillhub. All rights reserved.
//

import Foundation

/// Errors regarding a TillhubPointOfSaleSDK response encoding/decoding
///
/// - jsonEncoding: The response object could not be encoded to JSON data
/// - jsonDecoding: The JSON data could not be decoded to a response object
/// - dataEncoding: The response JSON data could not be encoded to JSON string
/// - dataDecoding: The response JSON string could not be decoded to JSON data
/// - urlEncoding: The response JSON string could not be encoded to URL
/// - urlDecoding: The response URL could not be decoded to JSON string
public enum TPOSResponseError: LocalizedError {
    case jsonEncoding(error: Error)
    case jsonDecoding(error: Error)
    case dataEncoding
    case dataDecoding
    case urlEncoding
    case urlDecoding
    
    public var errorDescription: String? {
        switch self {
        case .jsonEncoding(let error):
            return "The response object could not be encoded to JSON data (\(error.localizedDescription))."
        case .jsonDecoding(let error):
            return "The JSON data could not be decoded to a response object (\(error.localizedDescription))."
        case .dataEncoding:
            return "The response JSON data could not be encoded to JSON string."
        case .dataDecoding:
            return "The response JSON string could not be decoded to JSON data."
        case .urlEncoding:
            return "The response JSON string could not be encoded to URL."
        case .urlDecoding:
            return "The response URL could not be decoded to JSON string."
        }
    }
}


// MARK: - Extensions for serialization (used by Tillhub)
extension TPOSResponse {
    
    /// Creates a deep link URL from a TPOSResponse, pod-private
    /// - only the query items are added to the TPOSRequest.header.callbackUrl
    ///
    /// - Returns: deep link URL to call from the Tillhub application
    /// - Throws: encoding errors (JSON, URL)
    func url() throws -> URL {
        var data: Data
        do {
            data = try JSONEncoder().encode(self)
        } catch let error {
            throw TPOSRequestError.jsonEncoding(error: error)
        }
        guard let json = String(data: data, encoding: .utf8) else {
            throw TPOSResponseError.dataEncoding
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
        guard let url = components.url else { throw TPOSResponseError.urlEncoding }
        
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
                throw TPOSResponseError.urlDecoding
        }
        guard let data = json.data(using: .utf8) else {
            throw TPOSResponseError.dataDecoding
        }
        do {
            self = try JSONDecoder().decode(TPOSResponse.self, from: data)
        } catch let error {
            throw TPOSResponseError.jsonDecoding(error: error)
        }
    }
}
