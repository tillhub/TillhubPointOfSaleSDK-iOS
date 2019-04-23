//
//  TPOSMessageBuilder.swift
//  TillhubPointOfSaleSDK
//
//  Created by Andreas Hilbert on 30.01.19.
//  Copyright © 2019 Tillhub. All rights reserved.
//

import Foundation

public struct TPOSMessageBuilder {
    
    // MARK: transaction
    
    public static func transaction(view: TPOSView, payload: TPOSCart) -> TPOSMessage<TPOSCart> {
        return TPOSMessage(view: view, payload: payload)
    }
    
    // MARK: simple
    
    public static func simple(view: TPOSView, payload: TPOSCartReference) -> TPOSMessage<TPOSCartReference> {
        return TPOSMessage(view: view, payload: payload)
    }
}
