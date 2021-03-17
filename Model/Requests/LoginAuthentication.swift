//
//  LoginAuthentication.swift
//  OnTheMap
//
//  Created by Paul Smith on 3/7/21.
//

import Foundation

struct LoginAuthentication : Codable {
    let login: LoginRequest
    
    enum CodingKeys: String, CodingKey {
        case login = "udacity"
    }
}
