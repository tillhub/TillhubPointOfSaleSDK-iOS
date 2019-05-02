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
        // Do any additional setup after loading the view, typically from a nib.
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
            sendRequestButton.isEnabled = true
            switch result {
            case .success(let response):
                strongSelf.logTextView.text = "SUCCESS:\n\n\(response)"
            case .failure(let error):
                strongSelf.logTextView.text = "FAILURE:\n\n\(error.localizedDescription)"
            }
            
        }
    }
    
    private func sendRequest(completion: ResultCompletion<TPOSResponse>) {
        

    }
}

