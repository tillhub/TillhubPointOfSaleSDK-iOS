//
//  TPOSManager.swift
//  TillhubPointOfSaleSDK_Example
//
//  Created by Andreas Hilbert on 03.05.19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import TillhubPointOfSaleSDK


enum ActionPath: Int {
    case load = 0
    case checkout = 1
    
    func actionPath() -> TPOSRequestActionPath {
        switch self {
        case .load: return TPOSRequestActionPath.load
        case .checkout: return TPOSRequestActionPath.checkout
        }
    }
}

enum PayloadType: Int {
    case cart = 0
    case cartReference = 1
    
    func actionPath() -> TPOSRequestPayloadType {
        switch self {
        case .cart: return TPOSRequestPayloadType.cart
        case .cartReference: return TPOSRequestPayloadType.cartReference
        }
    }
}


enum TPOSManagerError: LocalizedError {
    case urlTypes
    case urlScheme
    case responseFailure(reason: String)
    
    public var errorDescription: String? {
        switch self {
        case .urlTypes:
            return "No URL types for TillhubPointOfSaleSDK found in application."
        case .urlScheme:
            return "No URL scheme found for TillhubPointOfSaleSDK URL type."
        case .responseFailure(let reason):
            return "The response reported an error - reason: \(reason)."
        }
    }
}

protocol TPOSMangerResponseDelegate {
    func received(url: String)
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
        delegate?.received(url: url.absoluteString)
        do {
            // currently the response object does not depend on the url path components
            // still, the path components will reflect the path of the request
            let response = try TPOSResponse(url: url)
            switch response.header.status {
            case .success:
                delegate?.responseReceived(result: .success("\(response)"))
            case .failure:
                let desc = response.header.localizedErrorDescription ?? "- no reason given -"
                delegate?.responseReceived(result: .failure(TPOSManagerError.responseFailure(reason: desc)))
            }
            return true
        } catch let error {
            delegate?.responseReceived(result: .failure(error))
            return false
        }
    }

    func sendCartRequest(account: String, actionPath: ActionPath, completion: @escaping ResultCompletion<String>) {
        do {
            let cartRequest = try createCartRequest(account: account, actionPath: actionPath.actionPath())
            TPOS.perform(request: cartRequest, test: true) { (error) in
                if let error = error { completion(.failure(error)) }
                else { completion(.success("\(cartRequest)")) }
            }
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func sendCartReferenceRequest(account: String, actionPath: ActionPath, reference: String, branch: String, completion: @escaping ResultCompletion<String>) {
        do {
            let cartReferenceRequest = try createCartReferenceRequest(account: account, actionPath: actionPath.actionPath(), reference: reference, branch: branch)
            TPOS.perform(request: cartReferenceRequest, test: true, completion: { (error) in
                if let error = error { completion(.failure(error)) }
                else { completion(.success("\(cartReferenceRequest)")) }
            })
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // MARK: - private examples
    
    private func createCartRequest(account: String, actionPath: TPOSRequestActionPath) throws -> TPOSRequest<TPOSCart> {
        
        let header = TPOSRequestHeader(clientID: account,
                                       actionPath: actionPath,
                                       payloadType: .cart,
                                       callbackUrlScheme: try callBackUrlScheme(),
                                       autoReturn: true,
                                       comment: "testing custom callback")
        
        // a minimal cart item
        let cartItem1 = try TPOSCartItem(productId: "84f82be1-29f7-4372-9f58-944966743991",
                                         currency: "EUR",
                                         pricePerUnit: 2.89,
                                         vatRate: 0.07)
        
        // a more complex cart item
        let discount1 = try TPOSCartItemDiscount(type: TPOSCartItemDiscountType.relative,
                                                value: 0.15,
                                                comment: "A 15% discount.")
        
        let discount2 = try TPOSCartItemDiscount(type: TPOSCartItemDiscountType.absolute,
                                                 value: 1.00,
                                                 comment: "A 1€ discount.")
        
        let cartItem2 = try TPOSCartItem(type: TPOSCartItemType.item,
                                         quantity: 2.0,
                                         productId: "9cf299ac-6ac3-4246-bf17-24e7f7812632",
                                         currency: "EUR",
                                         pricePerUnit: 2.89,
                                         vatRate: 0.19,
                                         title: "Test product",
                                         comment: "Palmolive Flüssigseife Milch & Honig 300ml",
                                         salesPerson: TPOSStaff(name: "Hubert Cumberdale", customId: "0089"),
                                         discounts: [discount1, discount2])
        
        let paymentIntent = TPOSPaymentIntent(allowedTypes: [TPOSPaymentType.cash],
                                              automaticType: TPOSPaymentAutomaticType.automaticCash)
        let cart = try TPOSCart(taxType: TPOSTaxType.inclusive,
                                items: [cartItem1, cartItem2],
                                paymentIntent: paymentIntent,
                                customId: "TPOS test cart request 0001",
                                title: "Cart Title 01",
                                comment: "m@n instant checkout",
                                customer: TPOSCustomer(name: "Marjory Stewart Baxter", customId: "000432001"),
                                cashier: TPOSStaff(name: "Jeremy Fisher", customId: "c_sdj_234"))
        return TPOSRequest(header: header, payload: cart)
    }
    
    private func createCartReferenceRequest(account: String, actionPath: TPOSRequestActionPath, reference: String, branch: String) throws -> TPOSRequest<TPOSCartReference> {
        let header = TPOSRequestHeader(clientID: account,
                                       actionPath: actionPath,
                                       payloadType: .cartReference,
                                       callbackUrlScheme: try callBackUrlScheme(),
                                       autoReturn: true,
                                       comment: "testing custom ref callback")
        let cartReference = try TPOSCartReference(cartId: reference,
                                                  branchId: branch,
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

