//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Paul Smith on 3/7/21.
//

import Foundation

class OTMClient {
    
    struct Auth {
        static var accountKey = ""
        static var sessionId = ""
    }
    
    enum MethodTypes : String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case getStudentLocations
        case postStudentLocation
        case putStudentLocation(String)
        case session
        case getUserData(String)
        case signIn
        case udacity
        
        var stringValue: String {
            switch self {
            case .getStudentLocations: return Endpoints.base + "/StudentLocation?limit=100&order=-updatedAt"
            case .postStudentLocation: return Endpoints.base + "/StudentLocation"
            case .putStudentLocation(let objectId): return Endpoints.base + "/StudentLocation/\(objectId)"
            case .session: return Endpoints.base + "/session"
            case .getUserData(let userId): return Endpoints.base + "/users/\(userId)"
            case .signIn: return "https://auth.udacity.com/sign-in?next=https://classroom.udacity.com"
            case .udacity: return "https://www.udacity.com/"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getStudentLocations(completion: @escaping ([StudentLocation]?, Error?) -> Void) {
        _ = taskForGETRequest(url: Endpoints.getStudentLocations.url, responseType: LocationResults.self, completion: {
            (response, error) in
            if let response = response {
                completion(response.results, error)
            }
            else {
                completion([], error)
            }
        })
    }
    
    class func postStudentLocation(location: LocationRequest, completion: @escaping (Bool, Error?) -> Void) {
        _ = taskForPOSTRequest(url: Endpoints.postStudentLocation.url, body: location, responseType: PostLocationResponse.self, completion: {
            (response, error) in
            if response != nil {
                completion(true, error)
            }
            else {
                completion(false, error)
            }
        })
    }
    
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let login = LoginAuthentication(login: LoginRequest(username: username, password: password))
        _ = taskForPOSTRequest(url: Endpoints.session.url, body: login, removeSecurity: true, responseType: SessionResponse.self, completion: {
            (response, error) in
            if let response = response {
                self.Auth.accountKey = response.account.key
                self.Auth.sessionId = response.session.id
                completion(true, error)
            }
            else {
                completion(false, error)
            }
        })
    }
    
    class func logout(completion: @escaping (Bool, Error?) -> Void) {
        _ = taskForDELETERequest(url: Endpoints.session.url, removeSecurity: true, responseType: LogoutResponse.self, completion: {
            (response, error) in
            if response?.session != nil {
                self.Auth.accountKey = ""
                self.Auth.sessionId = ""
                completion(true, error)
            }
            else {
                completion(false, error)
            }
        })
    }
    
    class func getUser(userId: String, completion: @escaping (User?, Error?) -> Void) {
        _ = taskForGETRequest(url: Endpoints.getUserData(userId).url, removeSecurity: true, responseType: User.self, completion: {
            (response, error) in
            if let response = response {
                completion(response, error)
            }
            else {
                completion(nil, error)
            }
        })
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, removeSecurity: Bool = false , responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        let request = URLRequest(url: url)
        let task = taskForData(urlRequest: request, removeSecurity: removeSecurity, responseType: responseType, completion: completion)
        return task
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, body: RequestType, removeSecurity: Bool = false, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        var request = URLRequest(url: url)
        
        request.httpMethod = MethodTypes.post.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try! encoder.encode(body)
        
        let task = taskForData(urlRequest: request, removeSecurity: removeSecurity, responseType: responseType, completion: completion)
        return task
    }
    
    class func taskForPUTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, body: RequestType, removeSecurity: Bool = false, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        var request = URLRequest(url: url)
        
        request.httpMethod = MethodTypes.put.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try! encoder.encode(body)
        
        let task = taskForData(urlRequest: request, removeSecurity: removeSecurity, responseType: responseType, completion: completion)
        return task
    }
        
    class func taskForDELETERequest<ResponseType: Decodable>(url: URL, removeSecurity: Bool = false, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        var request = URLRequest(url: url)
        
        request.httpMethod = MethodTypes.delete.rawValue
        var xsrfCookie: HTTPCookie? = nil
        for cookie in HTTPCookieStorage.shared.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = taskForData(urlRequest: request, removeSecurity: removeSecurity, responseType: responseType, completion: completion)
        return task
    }
    
    @discardableResult class func taskForData<ResponseType: Decodable>(urlRequest: URLRequest, removeSecurity: Bool, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in
            guard var data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            if(removeSecurity) {
                let range : Range = 5..<data.count
                data = data.subdata(in: range)
            }
            do {
//                print(String(data: data, encoding: .utf8)!)
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, error)
                }
            }
            catch {
                do {
                    let errorObject = try decoder.decode(OTMResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorObject)
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
}
