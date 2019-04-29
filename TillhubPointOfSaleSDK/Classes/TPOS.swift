//
//  TPOS.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 24.04.19.
//

import Foundation

public enum TPOSError: Error {
    case requestActionTypeDecoding
    case requestPayloadTypeDecoding
    case urlScheme
    case currencyIsoCodeError
}

public class TPOS {

    public struct Url {
        static let scheme = "TillhubPointOfSaleSDK"
        static let requestQuery = "request"
        static let responseQuery = "response"
    }
}

// MARK: - External application -> Tillhub
extension TPOS {

    static public func canPerform<T: Codable>(request: TPOSRequest<T>) throws -> Bool {
        guard (Bundle.main.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes") as? [String])?.contains(Url.scheme) == true else {
            throw TPOSError.urlScheme
        }
        return UIApplication.shared.canOpenURL(try request.url())
    }

    static public func perform<T: Codable>(request: TPOSRequest<T>, completion: @escaping ((Bool) -> ())) throws {
        if try TPOS.canPerform(request: request) {
            UIApplication.shared.open(try request.url(), options: [:], completionHandler: completion)
        }
    }
}

// MARK: - Tillhub -> external application
extension TPOS {
    
    public struct Constants {
        static let identifier = "org.cocoapods.TillhubPointOfSaleSDK"
        static let version = "CFBundleShortVersionString"
        static let unspecified = "unspecified"
    }
    
    static var podVersion: String = {
        return Bundle(identifier: Constants.identifier)?.infoDictionary?[Constants.version] as? String ?? Constants.unspecified
    }()
    
    static public func requestPayloadType(url: URL) throws -> TPOSRequestPayloadType {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else {
            throw TPOSRequestError.urlDecodingError
        }
        guard let requestPayloadType = TPOSRequestPayloadType(rawValue: host) else { throw TPOSError.requestPayloadTypeDecoding }
        return requestPayloadType
    }
    
    static public func requestActionType(url: URL) throws -> TPOSRequestActionType {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw TPOSRequestError.urlDecodingError
        }
        guard let requestActionType = TPOSRequestActionType(rawValue: components.path) else { throw TPOSError.requestActionTypeDecoding }
        return requestActionType
    }
    
    static public func canPerform(response: TPOSResponse) throws -> Bool {
        guard let scheme = URLComponents(url: response.header.url, resolvingAgainstBaseURL: true)?.scheme,
            (Bundle.main.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes") as? [String])?.contains(scheme) == true else {
                throw TPOSError.urlScheme
        }
        return UIApplication.shared.canOpenURL(response.header.url)
    }

    static public func perform(response: TPOSResponse, completion: @escaping ((Bool) -> ())) throws {
        if try TPOS.canPerform(response: response) {
            UIApplication.shared.open(try response.url(), options: [:], completionHandler: completion)
        }
    }
}
