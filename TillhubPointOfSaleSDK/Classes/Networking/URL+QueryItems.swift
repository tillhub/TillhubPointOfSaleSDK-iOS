//
//  URL+QueryItems.swift
//  TillhubPointOfSaleSDK
//
//  Created by lpylypenko on 22.05.17.
//  Copyright © 2017 Tillhub. All rights reserved.
//

import Foundation

extension URL {
    public var queryItems: [String: String] {
        var params = [String: String]()
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce([:], { (_, item) -> [String: String] in
                params[item.name] = item.value
                return params
            }) ?? [:]
    }
}
