//
//  TPOS.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 24.04.19.
//

import Foundation

/// Simplifying completion with optional error
public typealias ErrorCompletion = (_ error: Error?) -> ()

/// General TPOS errors regarding transport layer
///
/// - requestActionPathDecoding: action path for request could not be decoded
/// - requestPayloadTypeDecoding: request payload type could not be decoded
/// - applicationQueriesSchemeMissingFromApplication: requested scheme is not registered within the application
/// - cantOpenUrl: the URL can not be opened (by request to canOpenUrl)
/// - urlNotOpened: the URL was not opened (by request to openUrl)
public enum TPOSError: LocalizedError {
    case requestActionPathDecoding
    case requestPayloadTypeDecoding
    case applicationQueriesSchemeMissingFromApplication
    case cantOpenUrl
    case urlNotOpened
    
    public var errorDescription: String? {
        switch self {
        case .requestActionPathDecoding:
            return "action path for request could not be decoded"
        case .requestPayloadTypeDecoding:
            return "request payload type could not be decoded"
        case .applicationQueriesSchemeMissingFromApplication:
            return "requested scheme is not registered within the application"
        case .cantOpenUrl:
            return "the URL can not be opened"
        case .urlNotOpened:
            return "the URL was not opened"
        }
    }
}

/// General errors of a TPOS payload
///
/// - currencyIsoCodeNotFound: currency code does not exist
public enum TPOSPayloadError: Error {
    case currencyIsoCodeNotFound
}

/// Top level entry for TPOS transport layer actions
public class TPOS {

    /// Constants for URL building
    public struct Url {
        
        /// static url.host for a request
        public static let host = "TillhubPointOfSaleSDK"

        /// query item name for request data
        static let requestQuery = "request"
        
        /// query item name for response data
        static let responseQuery = "response"
    }
}

// MARK: - External application -> Tillhub
extension TPOS {

    /// Performs a request against the client target, e.g. "tillhub"
    /// the resulting URL ideally will be traget://request
    ///
    /// - Parameters:
    ///   - request: a TPOSRequest object (TPOSCart or TPOSCartReference)
    ///   - target: target scheme, e.g. "tillhub" - to be negotiated between both implementers
    ///   - test: indicate if the resulting URL can be parsed according to the available SDK methods
    ///   - completion: optional completion block with error
    static public func perform<T: Codable>(request: TPOSRequest<T>, target: String, test: Bool = false, completion: ErrorCompletion?) {
        do {
            guard (Bundle.main.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes") as? [String])?.contains(target) == true else {
                throw TPOSError.applicationQueriesSchemeMissingFromApplication
            }
            let url = try request.url(target)
            guard UIApplication.shared.canOpenURL(url) else {
                throw TPOSError.cantOpenUrl
            }
            if test {
                _ = try requestActionPath(url: url)
                let payloadType = try requestPayloadType(url: url)
                switch payloadType {
                case .cart:
                    _ = try TPOSRequest<TPOSCart>(url: url)
                case .cartReference:
                    _ = try TPOSRequest<TPOSCartReference>(url: url)
                }
            }
            UIApplication.shared.open(url, options: [:]) { (success) in
                success ? completion?(nil) : completion?(TPOSError.urlNotOpened)
            }
        } catch let error {
            completion?(error)
        }
    }
    
    /// Parses the indicated action path from a given URL
    ///
    /// - Parameter url: the deeplink URL to analyze
    /// - Returns: if successful, the indicated action path
    /// - Throws: url decoding or path decoding errors
    static public func requestActionPath(url: URL) throws -> TPOSRequestActionPath {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw TPOSRequestError.urlDecodingError
        }
        guard components.host == TPOS.Url.host else {
            throw TPOSRequestError.hostDecodingMismatch
        }
        let pathComponents = components.path.components(separatedBy: "/").filter({ $0.isEmpty == false })
        guard pathComponents.count == 2,
            let requestActionPath = TPOSRequestActionPath(rawValue: pathComponents[0]) else {
                throw TPOSRequestError.actionPathDecoding
        }
        return requestActionPath
    }
    
    /// Parses the indicated payload type from a given URL
    ///
    /// - Parameter url: the deeplink URL to analyze
    /// - Returns: if successful, the indicated payload type
    /// - Throws: url decoding or type decoding errors
    static public func requestPayloadType(url: URL) throws -> TPOSRequestPayloadType {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw TPOSRequestError.urlDecodingError
        }
        guard components.host == TPOS.Url.host else {
            throw TPOSRequestError.hostDecodingMismatch
        }
        let pathComponents = components.path.components(separatedBy: "/").filter({ $0.isEmpty == false })
        guard pathComponents.count == 2,
            let requestPayloadType = TPOSRequestPayloadType(rawValue: pathComponents[1]) else {
                throw TPOSRequestError.payloadTypeDecoding
        }
        return requestPayloadType
    }
}

// MARK: - Tillhub -> external application
extension TPOS {

    /// Performs a response against the callback of a request
    /// - TPOSResponse.header.url.scheme must conform to canOpenURL requirements (registered in LSApplicationQueriesSchemes)
    /// - existing query items in TPOSResponse.header.url will be kept if possible
    ///
    /// - Parameters:
    ///   - response: a TPOSResponse object with the url set in TPOSResponse.header.url
    ///   - test: indicate if the resulting URL can be parsed according to the available SDK methods
    ///   - completion: optional completion block with error
    static public func perform(response: TPOSResponse, test: Bool = false, completion: ErrorCompletion?) {
        do {
            guard (Bundle.main.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes") as? [String])?.contains(response.header.urlScheme) == true else {
                    throw TPOSError.applicationQueriesSchemeMissingFromApplication
            }
            let url = try response.url()
            guard UIApplication.shared.canOpenURL(url) else {
                throw TPOSError.cantOpenUrl
            }
            if test {
                _ = try TPOSResponse(url: url)
            }
            UIApplication.shared.open(url, options: [:]) { (success) in
                success ? completion?(nil) : completion?(TPOSError.urlNotOpened)
            }
        } catch let error {
            completion?(error)
        }
    }
    
}

// MARK: - Local usage
extension TPOS {
    
    public struct Constants {
        static let identifier = "org.cocoapods.TillhubPointOfSaleSDK"
        static let version = "CFBundleShortVersionString"
        static let unspecified = "unspecified"
    }
    
    static var podVersion: String = {
        return Bundle(identifier: Constants.identifier)?.infoDictionary?[Constants.version] as? String ?? Constants.unspecified
    }()
}
