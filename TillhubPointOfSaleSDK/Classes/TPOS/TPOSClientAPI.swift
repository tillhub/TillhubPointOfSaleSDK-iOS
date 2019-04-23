//
//  TPOSClientAPI.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 30.01.19.
//  Copyright © 2019 Tillhub. All rights reserved.
//

import Foundation

private class TPOSServerTrustPolicyManager: ServerTrustPolicyManager {
    
    init() {
        super.init(policies: [:])
    }
    
    override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
        return ServerTrustPolicy.disableEvaluation
    }
}


public class TPOSClientAPI: NSObject {
    public typealias Result<T> = Alamofire.Result<T>
    public typealias ResultCompletion<T> = (_ result: Result<T>) -> ()
    public typealias RequestResult<T> = ResultCompletion<T>
    
    public let baseURL: URL
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 6 // 6 sec
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        let policyManager = TPOSServerTrustPolicyManager() // Disable any evaluation
        return SessionManager(configuration: configuration, serverTrustPolicyManager: policyManager)
    }()
    
    private lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    // MARK: - Public
    
    public func cancelAllOperations() {
        sessionManager.session.getAllTasks { (tasks) in
            tasks.forEach { $0.cancel() }
        }
    }

    public func performRequest<T: Codable>(message requestMessage: TPOSMessage<T>, queue: DispatchQueue? = nil, logEnabled: Bool = false, completion: RequestResult<String>?)  {
        DataRequest.logEnabled = logEnabled
        sessionManager.request(self.baseURL, method: HTTPMethod.post, parameters: nil, encoding: EncodableJSONEncoding(object: requestMessage, encoder: encoder), headers: nil)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["text/plain"])
            .response { (response) in
                if let error = response.error {
                    completion?(.failure(error))
                } else {
                    if let data = response.data, let responseMessage = String(data: data, encoding: .utf8) {
                        completion?(.success(responseMessage))
                    } else {
                        completion?(.success("ok"))
                    }
                }
            }
            .log()
    }

}
