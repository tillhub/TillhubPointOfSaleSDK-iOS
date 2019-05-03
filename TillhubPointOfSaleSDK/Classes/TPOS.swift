//
//  TPOS.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 24.04.19.
//

import Foundation

public typealias ResultCompletion<T> = (_ result: Result<T, Error>) -> ()

public enum TPOSError: LocalizedError {
    case requestActionPathDecoding
    case requestPayloadTypeDecoding
    case applicationQueriesSchemeMissingFromApplication
    case currencyIsoCodeNotFound
    case urlNotOpened
    
    public var errorDescription: String? {
        return String(describing: self)
    }
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
            throw TPOSError.applicationQueriesSchemeMissingFromApplication
        }
        let url = try request.url()
        return UIApplication.shared.canOpenURL(url)
    }

    static public func perform<T: Codable>(request: TPOSRequest<T>, completion: ResultCompletion<Bool>?) {
        do {
            if try TPOS.canPerform(request: request) {
                UIApplication.shared.open(try request.url(), options: [:]) { (success) in
                    success ? completion?(.success(true)) : completion?(.failure(TPOSError.urlNotOpened))
                }
            }
        } catch let error {
            completion?(.failure(error))
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
    
    static public func requestActionPath(url: URL) throws -> TPOSRequestActionPath {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw TPOSRequestError.urlDecodingError
        }
        guard let requestActionPath = TPOSRequestActionPath(rawValue: components.path) else { throw TPOSError.requestActionPathDecoding }
        return requestActionPath
    }
    
    static public func canPerform(response: TPOSResponse) throws -> Bool {
        guard let scheme = URLComponents(url: response.header.url, resolvingAgainstBaseURL: true)?.scheme,
            (Bundle.main.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes") as? [String])?.contains(scheme) == true else {
                throw TPOSError.applicationQueriesSchemeMissingFromApplication
        }
        return UIApplication.shared.canOpenURL(response.header.url)
    }

    static public func perform(response: TPOSResponse, completion: ResultCompletion<Bool>?) {
        do {
            if try TPOS.canPerform(response: response) {
                UIApplication.shared.open(try response.url(), options: [:]) { (success) in
                    success ? completion?(.success(true)) : completion?(.failure(TPOSError.urlNotOpened))
                }
            }
        } catch let error {
            completion?(.failure(error))
        }
    }
}
