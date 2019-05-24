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
    case urlDecoding
    case requestActionPathDecoding
    case requestPayloadTypeDecoding
    case applicationQueriesSchemeMissingFromApplication
    case cantOpenUrl
    case urlNotOpened
    case versionMismatch
    
    public var errorDescription: String? {
        switch self {
        case .urlDecoding:
            return "The url could not be decoded."
        case .requestActionPathDecoding:
            return "The action path for request could not be decoded."
        case .requestPayloadTypeDecoding:
            return "The request payload type could not be decoded."
        case .applicationQueriesSchemeMissingFromApplication:
            return "The requested scheme is not registered within the application."
        case .cantOpenUrl:
            return "The URL can not be opened."
        case .urlNotOpened:
            return "The URL was not opened."
        case .versionMismatch:
            return "SDK versions do not match."
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
        
        /// static target for a request
        public static let requestScheme = "tillhub"
        
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
    static public func perform<T: Codable>(request: TPOSRequest<T>, test: Bool = false, completion: ErrorCompletion?) {
        do {
            guard (Bundle.main.object(forInfoDictionaryKey: Constants.queriesSchemes) as? [String])?.contains(Url.requestScheme) == true else {
                throw TPOSError.applicationQueriesSchemeMissingFromApplication
            }
            let url = try request.url()
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
            throw TPOSError.urlDecoding
        }
        guard components.host == TPOS.host else {
            throw TPOSError.versionMismatch
        }
        let pathComponents = components.path.components(separatedBy: "/").filter({ $0.isEmpty == false })
        guard pathComponents.count == 2,
            let requestActionPath = TPOSRequestActionPath(rawValue: pathComponents[0]) else {
                throw TPOSError.requestActionPathDecoding
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
            throw TPOSError.urlDecoding
        }
        guard components.host == TPOS.host else {
            throw TPOSError.versionMismatch
        }
        let pathComponents = components.path.components(separatedBy: "/").filter({ $0.isEmpty == false })
        guard pathComponents.count == 2,
            let requestPayloadType = TPOSRequestPayloadType(rawValue: pathComponents[1]) else {
                throw TPOSError.requestPayloadTypeDecoding
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
            guard (Bundle.main.object(forInfoDictionaryKey: Constants.queriesSchemes) as? [String])?.contains(response.header.urlScheme) == true else {
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
    
    /// Constants for pod-internal usage
    struct Constants {
        
        /// key to find allowed queries schemes
        static let queriesSchemes = "LSApplicationQueriesSchemes"
        
        /// bundle identifier key: pod
        static let identifier = "org.cocoapods.TillhubPointOfSaleSDK"
        
        /// info dictionary key: bundle version
        static let version = "CFBundleShortVersionString"
        
        /// info dictionary key: display name
        static let display = "CFBundleDisplayName"
        
        /// version value: unsepecified
        static let unspecified = "unspecified"
    }
    
    /// retrieve the version of this SDK
    static var podVersion: String = {
        return Bundle(identifier: Constants.identifier)?.infoDictionary?[Constants.version] as? String ?? Constants.unspecified
    }()
    
    /// retrieve the display name of the calling application
    static var displayName: String = {
        return Bundle.main.infoDictionary?[TPOS.Constants.display] as? String ?? Constants.unspecified
    }()

    /// retrieve the host component as e.g. "TillhubPointOfSaleSDK_0_2"
    static var host: String = {
        let components = TPOS.podVersion.components(separatedBy: ".").filter({ $0.isEmpty == false })
        let shortened = components.prefix(2).joined(separator: "_")
        return "\(TPOS.Url.host)_\(shortened)"
    }()
}
