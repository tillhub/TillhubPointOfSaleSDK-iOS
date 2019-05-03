//
//  TPOSManager.swift
//  TillhubPointOfSaleSDK_Example
//
//  Created by Andreas Hilbert on 03.05.19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import TillhubPointOfSaleSDK

enum TPOSManagerError: LocalizedError {
    case urlTypes
    case urlScheme
    case url
}

protocol TPOSMangerResponseDelegate {
    func responseReceived(result: Result<String, Error>)
}

class TPOSManager {
    
    // MARK: - Public
    
    static let shared = TPOSManager()
    
    var delegate: TPOSMangerResponseDelegate?
    
    private struct Constants {
        static let target = "tillhub"
    }
    
    func handle(url: URL) -> Bool {
        do {
            // currently the response object does not depend on the url path components
            // still, the path components will reflect the path of the request
            let response = try TPOSResponse(url: url)
            delegate?.responseReceived(result: .success("\(response)"))
            return true
        } catch let error {
            delegate?.responseReceived(result: .failure(error))
            return false
        }
    }
    
    func sendCartRequest(completion: @escaping ResultCompletion<String>) {
        do {
            let cartRequest = try createCartRequest()
            TPOS.perform(request: cartRequest, target: Constants.target, test: true) { (error) in
                if let error = error { completion(.failure(error)) }
                else { completion(.success("\(cartRequest)")) }
            }
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func sendCartReferenceRequest(completion: @escaping ResultCompletion<String>) {
        do {
            let cartReferenceRequest = try createCartReferenceRequest()
            TPOS.perform(request: cartReferenceRequest, target: Constants.target, test: true, completion: { (error) in
                if let error = error { completion(.failure(error)) }
                else { completion(.success("\(cartReferenceRequest)")) }
            })
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // MARK: - private examples
    
    private func createCartRequest() throws -> TPOSRequest<TPOSCart> {
        let header = TPOSRequestHeader(clientID: "d850c442-66ac-44dc-aaa0-37b051dbae5e",
                                       actionPath: .checkout,
                                       payloadType: .cart,
                                       callbackUrlScheme: try callBackUrlScheme(),
                                       autoReturn: true,
                                       comment: "testing custom callback")
        
        let cartItem1 = try TPOSCartItem(productId: "c23405ff-54b2-4353-9797-e8c5328d213b",
                                         currency: "EUR",
                                         pricePerUnit: 99.95,
                                         vatRate: 0.19)
        let cartItem2 = try TPOSCartItem(productId: "4fa256e2-432e-4e2e-bffc-a9f33a9a848c",
                                         currency: "EUR",
                                         pricePerUnit: 4.10,
                                         vatRate: 0.07)
        
        let cart = try TPOSCart(taxType: .inclusive,
                                items: [cartItem1, cartItem2],
                                paymentIntent: TPOSPaymentIntent(),
                                customId: "TPOS test cart request 0001",
                                title: "Cart Title 01",
                                comment: "m@n instant checkout",
                                customer: TPOSCustomer(name: "Anja Krüger", customId: "000432001"),
                                cashier: TPOSStaff(name: "Hans Meyer", customId: "c_sdj_234"))
        return TPOSRequest(header: header, payload: cart)
    }
    
    private func createCartReferenceRequest() throws -> TPOSRequest<TPOSCartReference> {
        let header = TPOSRequestHeader(clientID: "d850c442-66ac-44dc-aaa0-37b051dbae5e",
                                       actionPath: .load,
                                       payloadType: .cartReference,
                                       callbackUrlScheme: try callBackUrlScheme(),
                                       autoReturn: true,
                                       comment: "testing custom ref callback")
        let cartReference = try TPOSCartReference(cartId: "53476a5a-38e1-4c91-b415-17b00194861d",
                                                  branchId: "af03b5da-3bd2-439b-bdf8-fbf7e0515137",
                                                  paymentIntent: TPOSPaymentIntent(allowedTypes: [.card], automaticType: .automaticCash))
        return TPOSRequest(header: header, payload: cartReference)
    }

    private func callBackUrlScheme() throws -> String {
        guard let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] else {
            throw TPOSManagerError.urlTypes
        }
        guard let tillhubType = urlTypes.filter({ $0["CFBundleURLName"] as? String == TPOS.Url.host }).first else {
            throw TPOSManagerError.urlTypes
        }
        guard let myScheme = (tillhubType["CFBundleURLSchemes"] as? [String])?.first else {
            throw TPOSManagerError.urlScheme
        }
        
        return myScheme
    }
}

