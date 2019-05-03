//
//  TPOS.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 24.04.19.
//

import Foundation

/// Wrapping as Alamofire style result completion
public typealias ResultCompletion<T> = (_ result: Result<T, Error>) -> ()

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

        /// query item name for request data
        static let requestQuery = "request"
        
        /// query item name for response data
        static let responseQuery = "response"
    }
}

// MARK: - External application -> Tillhub
extension TPOS {

    static public func perform<T: Codable>(request: TPOSRequest<T>, scheme: String = "tillhub", testUrl: Bool = false, completion: ResultCompletion<Bool>?) {
        do {
            guard (Bundle.main.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes") as? [String])?.contains(scheme) == true else {
                throw TPOSError.applicationQueriesSchemeMissingFromApplication
            }
            let url = try request.url(scheme)
            guard UIApplication.shared.canOpenURL(url) else {
                throw TPOSError.cantOpenUrl
            }
            if testUrl {
                let payloadType = try requestPayloadType(url: url)
                switch payloadType {
                case .cart:
                    _ = try TPOSRequest<TPOSCart>(url: url)
                case .cartReference:
                    _ = try TPOSRequest<TPOSCartReference>(url: url)
                }
            }
            UIApplication.shared.open(url, options: [:]) { (success) in
                success ? completion?(.success(true)) : completion?(.failure(TPOSError.urlNotOpened))
            }
        } catch let error {
            completion?(.failure(error))
        }
    }
}

// MARK: - Tillhub -> external application
extension TPOS {
    
    static public func requestPayloadType(url: URL) throws -> TPOSRequestPayloadType {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else {
            throw TPOSRequestError.urlDecodingError
        }
        guard let requestPayloadType = TPOSRequestPayloadType(rawValue: host) else { throw TPOSError.requestPayloadTypeDecoding }
        return requestPayloadType
    }
    
    static public func requestActionPath(url: URL) throws -> TPOSRequestActionPath {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw TPOSRequestError.urlDecodingError
        }
        guard let requestActionPath = TPOSRequestActionPath(rawValue: components.path) else { throw TPOSError.requestActionPathDecoding }
        return requestActionPath
    }

    static public func perform(response: TPOSResponse, testUrl: Bool = false, completion: ResultCompletion<Bool>?) {
        do {
            guard let scheme = URLComponents(url: response.header.url, resolvingAgainstBaseURL: true)?.scheme,
                (Bundle.main.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes") as? [String])?.contains(scheme) == true else {
                    throw TPOSError.applicationQueriesSchemeMissingFromApplication
            }
            let url = try response.url()
            guard UIApplication.shared.canOpenURL(url) else {
                throw TPOSError.cantOpenUrl
            }
            if testUrl {
                _ = try TPOSResponse(url: url)
            }
            UIApplication.shared.open(url, options: [:]) { (success) in
                success ? completion?(.success(true)) : completion?(.failure(TPOSError.urlNotOpened))
            }
        } catch let error {
            completion?(.failure(error))
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
