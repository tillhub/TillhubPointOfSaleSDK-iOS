//
//  ViewController.swift
//  TillhubPointOfSaleSDK
//
//  Created by alghanor on 04/11/2019.
//  Copyright (c) 2019 alghanor. All rights reserved.
//

import UIKit
import TillhubPointOfSaleSDK

class ViewController: UIViewController {
    @IBOutlet weak var sendRequestButton: UIButton!
    @IBOutlet weak var logTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logTextView.text = "WELCOME"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendRequestTapped(_ sender: Any) {
        logTextView.text = ""
        sendRequestButton.isEnabled = false
        sendRequest { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.sendRequestButton.isEnabled = true
            switch result {
            case .success(let text):
                strongSelf.logTextView.text.append("SUCCESS:\n\n\(text)")
            case .failure(let error):
                strongSelf.logTextView.text.append("FAILURE:\n\n\(error.localizedDescription)")
            }
        }
    }
    
    private func sendRequest(completion: @escaping ResultCompletion<String>) {
        let alertController = UIAlertController(title: "Request Type", message: "Please select one of the available types", preferredStyle: .alert)
        
        let cartAction = UIAlertAction(title: "Cart", style: .default) { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.sendCartRequest(completion: completion)
        }
        alertController.addAction(cartAction)
        
        let cartReferenceAction = UIAlertAction(title: "Cart Reference", style: .default) { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.sendCartReferenceRequest(completion: completion)
        }
        alertController.addAction(cartReferenceAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            completion(.failure(CocoaError(.userCancelled)))
        }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func sendCartRequest(completion: @escaping ResultCompletion<String>) {
        do {
            let cartRequest = try createCartRequest()
            if try TPOS.canPerform(request: cartRequest) {
                TPOS.perform(request: cartRequest, completion: { (result) in
                    switch result {
                    case .success(_):
                        completion(.success("\(cartRequest)"))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
            }
        } catch let error {
            completion(.failure(error))
        }
    }
    
    private func sendCartReferenceRequest(completion: @escaping ResultCompletion<String>) {
        do {
            let cartReferenceRequest = try createCartReferenceRequest()
            if try TPOS.canPerform(request: cartReferenceRequest) {
                TPOS.perform(request: cartReferenceRequest, completion: { (result) in
                    switch result {
                    case .success(_):
                        completion(.success("\(cartReferenceRequest)"))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
            }
        } catch let error {
            completion(.failure(error))
        }
    }
    
    private func createCartRequest() throws -> TPOSRequest<TPOSCart> {
        let header = TPOSRequestHeader(clientID: "d850c442-66ac-44dc-aaa0-37b051dbae5e",
                                       actionType: .checkout,
                                       payloadType: .cart)
        
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
                                paymentIntent: try TPOSPaymentIntent(allowedTypes: [.cash], paymentId: nil, automatic: true),
                                customId: "TPOS test cart request 0001",
                                title: "Cart Title 01",
                                comment: "m@n instant checkout",
                                customer: TPOSCustomer(name: "Anja Krüger", customId: "000432001"),
                                cashier: TPOSStaff(name: "Hans Meyer", customId: "c_sdj_234"))
        return TPOSRequest.init(header: header, payload: cart)
    }
    
    private func createCartReferenceRequest() throws -> TPOSRequest<TPOSCartReference> {
        let header = TPOSRequestHeader(clientID: "d850c442-66ac-44dc-aaa0-37b051dbae5e",
                                       actionType: .load,
                                       payloadType: .cartReference)
        let cartReference = try TPOSCartReference(cartId: "53476a5a-38e1-4c91-b415-17b00194861d",
                                                  branchId: "af03b5da-3bd2-439b-bdf8-fbf7e0515137",
                                                  paymentIntent: try TPOSPaymentIntent(allowedTypes: [.card], paymentId: nil, automatic: true))
        return TPOSRequest.init(header: header, payload: cartReference)
    }
}

