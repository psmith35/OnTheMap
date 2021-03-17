//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Paul Smith on 3/7/21.
//

struct StudentLocation : Codable {
    let createdAt: String
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaURL: String
    let objectId: String
    let uniqueKey: String
    let updatedAt: String
    
    var firstNameString: String {
        let firstName = self.firstName.isEmpty ? "Human" : self.firstName
        return firstName
    }
    
    var lastNameString: String {
        let lastName = self.lastName.isEmpty ? "Person" : self.lastName
        return lastName
    }
    
    var urlString : String {
        let urlString = mediaURL.isEmpty ? OTMClient.Endpoints.udacity.stringValue : mediaURL
        return urlString
    }
}
