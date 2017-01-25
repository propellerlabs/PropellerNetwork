//
//  Resource.swift
//  PropellerNetworkKit
//
//  Created by Roy McKenzie on 1/18/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

typealias JSONObject = [String: Any]
typealias Parameters = [String: Any]
typealias HTTPHeaders = [String: String]

/// WebService error
enum WebServiceError: Error {
    case creatingRequestFailed
    case parsingResponseFailed
    case unacceptableStatusCode(code: Int)
    case unknown
}

/// HTTP method mapping for`Resource` and `URLRequest` objects
enum HTTPMethod: String {
    case get
    case delete
    case patch
    case post
    case put
}

private let acceptableStatusCodes = Array(200..<300)

/// Resource is analagous to an endpoint
struct Resource<A> {
    typealias JSONParse = (JSONObject) -> A?
    
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
    /// Parse
    let parsing: JSONParse?

    
    /// Initializer with some common default values
    init(urlPath: String,
         method: HTTPMethod = .get,
         parameters: Parameters? = nil,
         headers: [String: String]? = nil,
         encoding: ParameterEncoding = JSONEncoder.default,
         parsing: JSONParse? = nil) {
        
        self.urlPath    = urlPath
        self.method     = method
        self.parameters = parameters
        self.headers    = headers
        self.encoding   = encoding
        self.parsing    = parsing
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
    ///     - configuration: a configuration conforming to `ResourceRequestConfiguring`
    ///     - completion: `(A?, Error?) -> Void`
    func request(configuration: ResourceRequestConfiguring, completion: @escaping RequestCompletion) {
        
        // Build `URLRequest` with this resource
        let request: URLRequest
        
        do {
            request = try configuration.requestWith(self)
        } catch {
            completion(nil, error)
            return
        }
        
        // Perform `dataTask` with `shared` `URLSession` and resource request
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Error case
            if let error = error {
                NSLog("Failed performing `URLSession` `dataTask` for resource: \(self.description)")
                completion(nil, error)
                return
            }
            
            // Check response code
            if let response = response as? HTTPURLResponse {
                if !acceptableStatusCodes.contains(response.statusCode) {
                    let error = WebServiceError.unacceptableStatusCode(code: response.statusCode)
                    completion(nil, error)
                    return
                }
            }
            
            // For void types we will not be handling data
            if A.self is Void.Type {
                completion(() as? A, nil)
                return
            }
            
            // Data response case
            if let data = data {
                
                let jsonObject: JSONObject
                
                do {
                    jsonObject = try JSONDecoding.decode(data)
                } catch {
                    completion(nil, error)
                    return
                }
                
                // Parse object
                let object = self.parsing?(jsonObject)
                completion(object, nil)
                
                return
            }
            
            // Nil data and error case
            completion(nil, nil)
        }
        .resume()
    }
}

// TODO:- Request Resource with Promise
