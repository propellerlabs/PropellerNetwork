//
//  Resource.swift
//  PropellerNetworkKit
//
//  Created by Roy McKenzie on 1/18/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

typealias JSONObject = [String: Any]
typealias Parameters = [String: CustomStringConvertible]
typealias HTTPHeaders = [String: String]

enum WebServiceError: Error {
    case creatingRequestFailed
    case parsingResponseFailed
}

/// HTTP method mapping for`Resource` and `URLRequest` objects
enum HTTPMethod: String {
    case get
    case delete
    case patch
    case post
    case put
}

/// Resource is analagous to an endpoint
struct Resource<A> {
    typealias ResourceDecoding = (Data) -> A
    
    /// Resource API endpoint URL path
    let urlPath: String
    /// Method (post, get, etc.)
    let method: HTTPMethod
    /// Parameters for request body
    let parameters: Parameters?
    /// Additional headers for request
    let headers: [String: String]?
    /// Parameter encoding
    let encoding: ParameterEncoding
    /// Response decoding
    let decoding: ResourceDecoding?
}

// MARK:- Convenience Resource initializer
extension Resource {
    
    /// Initializer with some common default values
    init(urlPath: String) {
        self.urlPath = urlPath
        self.method = .get
        self.parameters = nil
        self.headers = nil
        self.encoding = JSONEncoding.default
        self.decoding = nil
    }
}

// MARK:- CustomStringConvertible
extension Resource: CustomStringConvertible {
    
    /// Description of resource
    var description: String {
        return "\(method.rawValue) to \(urlPath)"
    }
}

// MARK:- Request Resource
extension Resource {
    typealias RequestCompletion = (A?, Error?) -> Void
    
    /// Requests a resource with completion via `URLSession` `dataTask`
    ///
    /// - Parameters:
    ///     - completion: `(A?, Error?) -> Void`
    func request(credentialsProvider: ResourceAPI = .default, completion: @escaping RequestCompletion) {
        
        // Build `URLRequest` with this resource
        let credentialedRequest = try! credentialsProvider.credential(self)
        
        // Perform `dataTask` with `shared` `URLSession` and resource request
        URLSession.shared.dataTask(with: credentialedRequest) { data, _, error in
            
            // Error case
            if let error = error {
                NSLog("Failed performing `URLSession` `dataTask` for resource: \(self.description)")
                completion(nil, error)
                return
            }
            
            // Data response case
            if let data = data {
                NSLog("Successfully recieved data for resource: \(self.description)")
                let object = self.decoding?(data)
                completion(object, nil)
                return
            }
            
            // Nil data and error case
            completion(nil, nil)
        }
        .resume()
        
    }
}

struct ResourceAPI: ResourceCredentialing {
    let basePath: String
    let additionalHeaders: [String: String]?
    let credentials: ResourceCredentials?
    
    static var `default` = ResourceAPI(basePath: "https://www.apibasepath.com/",
                                       additionalHeaders: nil,
                                       credentials: nil)
    
    func credential<A>(_ resource: Resource<A>) throws -> URLRequest {
        
        // Set url
        guard let url = URL(string: basePath)?.appendingPathComponent(resource.urlPath) else {
            throw WebServiceError.creatingRequestFailed
        }
        
        // Create request and set method
        var request = URLRequest(url: url)
        request.httpMethod = resource.method.rawValue
        
        // Add headers
        resource.headers?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        // Add parameters
        if let parameters = resource.parameters,
           let encodedRequest = try? resource.encoding.encode(request, parameters: parameters) {
            request = encodedRequest
        }
        
        // Add additional headers
        additionalHeaders?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        // Add Auth header
        if let credentials = credentials, let authAccessToken = credentials.authAccessToken {
            request.addValue(authAccessToken, forHTTPHeaderField: credentials.authHeader)
        }
        
        return request
    }
}

private let APICredentialsAccessTokenKey = "APICredentialsAccessTokenKey"
struct ResourceCredentials {
    let authHeader: String
    
    var authAccessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: APICredentialsAccessTokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: APICredentialsAccessTokenKey)
        }
    }
}



