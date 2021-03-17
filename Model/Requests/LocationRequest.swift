//
//  LocationRequest.swift
//  OnTheMap
//
//  Created by Paul Smith on 3/9/21.
//

import Foundation

struct LocationRequest : Codable {
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    var latitude: Double
    var longitude: Double
}
