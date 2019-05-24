//
//  ViewController.swift
//  TillhubPointOfSaleSDK
//
//  Created by alghanor on 04/11/2019.
//  Copyright (c) 2019 alghanor. All rights reserved.
//

import UIKit

typealias ResultCompletion<T> = (_ result: Result<T, Error>) -> ()


class ViewController: UIViewController, TPOSMangerResponseDelegate {
    
    private enum InputError: LocalizedError {
        case accountNotSet
        case referenceNotSet
        case branchNotSet
    }
    
    @IBOutlet weak var actionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var payloadSegementedControl: UISegmentedControl!
    
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var branchTextField: UITextField!
    @IBOutlet weak var cartTextField: UITextField!
    
    @IBOutlet weak var branchStackView: UIStackView!
    @IBOutlet weak var cartStackView: UIStackView!
    @IBOutlet weak var sendRequestButton: UIButton!
    @IBOutlet weak var logTextView: UITextView!
    
    private var requestActionPath: ActionPath = ActionPath.load
    private var requestPayloadType: PayloadType = PayloadType.cart {
        didSet {
            branchStackView.isHidden = (requestPayloadType == PayloadType.cart)
            cartStackView.isHidden = (requestPayloadType == PayloadType.cart)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logTextView.text = "WELCOME"
        TPOSManager.shared.delegate = self
        
        requestActionPath = .load
        requestPayloadType = .cart
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendRequestTapped(_ sender: Any) {
        resetTextView()
        sendRequestButton.isEnabled = false
        sendRequest { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.sendRequestButton.isEnabled = true
            switch result {
            case .success(let text):
                strongSelf.append(text: "REQUEST SUCCESS:\n\n\(text)\n\n")
            case .failure(let error):
                strongSelf.append(text: "REQUEST FAILURE:\n\n\(error.localizedDescription)\n\n")
            }
        }
    }
    
    // MARK: - TPOSMangerResponseDelegate
    
    func received(url: String) {
        append(text: "URL RECEIVED:\n\n\(url)\n\n")
    }
    
    func responseReceived(result: Result<String, Error>) {
        switch result {
        case .success(let text):
            append(text: "RESPONSE SUCCESS:\n\n\(text)\n\n")
        case .failure(let error):
            append(text: "RESPONSE FAILURE:\n\n\(error.localizedDescription)\n\n")
        }
    }
    
    // MARK: - private helper
    
    private func sendRequest(completion: @escaping ResultCompletion<String>) {
        guard let account = accountTextField.text, account.isEmpty == false else {
            completion(.failure(InputError.accountNotSet))
            return
        }
        switch requestPayloadType {
        case .cart:
            TPOSManager.shared.sendCartRequest(account: account, actionPath: requestActionPath, completion: completion)
        case .cartReference:
            guard let reference = cartTextField.text, reference.isEmpty == false else {
                completion(.failure(InputError.referenceNotSet))
                return
            }
            guard let branch = branchTextField.text, branch.isEmpty == false else {
                completion(.failure(InputError.branchNotSet))
                return
            }
            TPOSManager.shared.sendCartReferenceRequest(account: account, actionPath: requestActionPath, reference: reference, branch: branch, completion: completion)
        }
    }

    @IBAction func actionChanged(_ sender: UISegmentedControl) {
        requestActionPath = ActionPath(rawValue: sender.selectedSegmentIndex) ?? ActionPath.load
    }
    
    @IBAction func payloadChanged(_ sender: UISegmentedControl) {
        requestPayloadType = PayloadType(rawValue: sender.selectedSegmentIndex) ?? PayloadType.cart
    }
    
    private func append(text: String) {
        logTextView.text.append(text)
        logTextView.scrollRangeToVisible(NSMakeRange(logTextView.text.count-1, 1))
    }
    
    private func resetTextView() {
        logTextView.text = ""
        logTextView.scrollRangeToVisible(NSMakeRange(logTextView.text.count-1, 1))
    }
}

