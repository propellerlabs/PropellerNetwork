//
//  WebService.swift
//  PropellerNetwork
//
//  Created by Roy McKenzie on 2/2/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

private let acceptableStatusCodes = Array(200..<300)

/// WebService error
enum WebServiceError: Error {
    case creatingRequestFailed
    case parsingResponseFailed
    case unacceptableStatusCode(code: Int)
    case unknown
}

/// Makes requests
struct WebService {
    
    /// Requests a resource with completion via `URLSession` `dataTask`
    ///
    /// - Parameters:
    ///     - configuration: a configuration conforming to `ResourceRequestConfiguring`
    ///     - completion: `(A?, Error?) -> Void`
    public static func request<A>(_ resource: Resource<A>, completion: @escaping (A?, Error?) -> Void) {
        
        // Build `URLRequest` with this resource
        let request: URLRequest
        
        do {
            request = try urlRequestWith(resource)
        } catch {
            completion(nil, error)
            return
        }
        
        // Perform `dataTask` with `shared` `URLSession` and resource request
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Error case
            if let error = error {
                NSLog("Failed performing `URLSession` `dataTask` for resource: \(resource.description)")
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
                    jsonObject = try JSONDecoder.decode(data)
                } catch {
                    completion(nil, error)
                    return
                }
                
                // Parse object
                let object = resource.parsing?(jsonObject)
                completion(object, nil)
                
                return
            }
            
            // Nil data and error case
            completion(nil, nil)
            }
            .resume()
    }
    
    /// Configures and credentials a `URLRequest` for a `Resource<A>`
    ///
    /// - Returns: A `URLRequest` for this resource
    internal static func urlRequestWith<A>(_ resource: Resource<A>) throws -> URLRequest {
        
        let configuration = resource.configuration
        
        // Set url
        guard let url = URL(string: configuration.basePath)?.appendingPathComponent(resource.urlPath) else {
            throw WebServiceConfigurationError.couldNotBuildUrl
        }
        
        // Create request and set method
        var request = URLRequest(url: url)
        request.httpMethod = resource.method.rawValue
        
        // Add headers
        resource.headers?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        // Add parameters
        if let parameters = resource.parameters {
            do {
                request = try resource.encoding.encode(request, parameters: parameters)
            } catch {
                throw error
            }
        }
        
        // Add additional headers
        configuration.additionalHeaders?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        // Add Auth header
        if let credential = configuration.credential, let authAccessToken = credential.authAccessToken {
            request.addValue(authAccessToken, forHTTPHeaderField: credential.authHeaderKey)
        }
        
        return request
    }
}
