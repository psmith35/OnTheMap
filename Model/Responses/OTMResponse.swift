//
//  OTMResponse.swift
//  OnTheMap
//
//  Created by Paul Smith on 3/7/21.
//

import Foundation

struct OTMResponse : Codable {
    let error: String
    let status: Int
}

extension OTMResponse : LocalizedError {
    var errorDescription: String? {
        return error
    }
}
