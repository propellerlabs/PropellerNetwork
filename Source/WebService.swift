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
public enum WebServiceError: Error {
    case creatingRequestFailed
    case parsingResponseFailed
    case noParserProvided
    case unacceptableStatusCode(code: Int, data: Data?)
    case parametersWithoutEncoding
    case unknown
}

extension WebServiceError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .creatingRequestFailed:
            return NSLocalizedString("Could not create URLRequest", comment: "")
        case .noParserProvided:
            return NSLocalizedString("No parser was provided for Resource", comment: "")
        case .parsingResponseFailed:
            return NSLocalizedString("Could not parse response", comment: "")
        case .unacceptableStatusCode(let statusCode):
            return NSLocalizedString("Returned bad status code: \(statusCode)", comment: "")
        case .parametersWithoutEncoding:
            return NSLocalizedString("You tried to encode parameters without specifying encoding", comment: "")
        case .unknown:
            return NSLocalizedString("An unknown error occured", comment: "")        }
    }
}

/// Makes requests
public struct WebService {
    
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
                    let error = WebServiceError.unacceptableStatusCode(code: response.statusCode, data: data)
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
                
                let jsonObject: Any
                
                do {
                    jsonObject = try JSONDecoder.decode(data)
                } catch {
                    completion(nil, error)
                    return
                }
                
                guard let parser = resource.parsing else {
                    let error = WebServiceError.noParserProvided
                    completion(nil, error)
                    return
                }
                
                // Parse object
                do {
                    let object = try parser(jsonObject)
                    completion(object, nil)
                } catch {
                    completion(nil, error)
                }
                
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
        
        let resourceUrl: URL
        
        // Set URL
        if let basePath = configuration.basePath, !basePath.isEmpty {
            guard let url = URL(string: basePath)?.appendingPathComponent(resource.urlPath) else {
                throw WebServiceConfigurationError.couldNotBuildUrl
            }
            resourceUrl = url
        } else {
            guard let url = URL(string: resource.urlPath) else {
                throw WebServiceConfigurationError.couldNotBuildUrl
            }
            resourceUrl = url
        }

        
        // Create request and set method
        var request = URLRequest(url: resourceUrl)
        request.httpMethod = resource.method.rawValue.uppercased()
        
        // Add headers
        resource.headers?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        // Add parameters
        if let parameters = resource.parameters {
            guard let encoding = resource.encoding else {
                throw WebServiceError.parametersWithoutEncoding
            }
            do {
                request = try encoding.encode(request, parameters: parameters)
            } catch {
                throw error
            }
        }
        
        // Add additional headers
        configuration.additionalHeaders?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        // Add Auth header
        if let credential = configuration.credential {
            request = credential.applyTo(request)
        }
        
        return request
    }
}
