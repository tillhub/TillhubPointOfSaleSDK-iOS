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
    
    public static func cart(header: TPOSRequestHeader, payload: TPOSCart) -> TPOSRequest<TPOSCart> {
        return TPOSRequest(header: header, payload: payload)
    }
    
    // MARK: simple
    
    public static func cartReference(header: TPOSRequestHeader, payload: TPOSCartReference) -> TPOSRequest<TPOSCartReference> {
        return TPOSRequest(header: header, payload: payload)
    }
}
