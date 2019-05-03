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
    
    @IBOutlet weak var sendRequestButton: UIButton!
    @IBOutlet weak var logTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logTextView.text = "WELCOME"
        TPOSManager.shared.delegate = self
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
                strongSelf.logTextView.text.append("REQUEST SUCCESS:\n\n\(text)")
            case .failure(let error):
                strongSelf.logTextView.text.append("REQUEST FAILURE:\n\n\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - TPOSMangerResponseDelegate
    
    func responseReceived(result: Result<String, Error>) {
        switch result {
        case .success(let text):
            logTextView.text.append("RESPONSE SUCCESS:\n\n\(text)")
        case .failure(let error):
            logTextView.text.append("RESPONSE FAILURE:\n\n\(error.localizedDescription)")
        }
    }
    
    // MARK: - private helper
    
    private func sendRequest(completion: @escaping ResultCompletion<String>) {
        let alertController = UIAlertController(title: "Request Type", message: "Please select one of the available types", preferredStyle: .alert)
        
        let cartAction = UIAlertAction(title: "Cart", style: .default) { (action) in
            TPOSManager.shared.sendCartRequest(completion: completion)
        }
        alertController.addAction(cartAction)
        
        let cartReferenceAction = UIAlertAction(title: "Cart Reference", style: .default) { (action) in
            TPOSManager.shared.sendCartReferenceRequest(completion: completion)
        }
        alertController.addAction(cartReferenceAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            completion(.failure(CocoaError(.userCancelled)))
        }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}

