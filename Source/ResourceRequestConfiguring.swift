//
//  ResourceRequestConfiguring.swift
//  PropellerNetwork
//
//  Created by Roy McKenzie on 1/18/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

enum ResourceRequestConfigurationError: Error {
    case couldNotBuildUrl
}

/// Protocol for configuring a `URLRequest` for a resource credentials on a request
public protocol ResourceRequestConfiguring {
    var basePath: String { get }
    var additionalHeaders: [String: String]? { get }
    var credential: ResourceRequestCredential? { get }
}

extension ResourceRequestConfiguring {
    
    /// Configures and credentials a `URLRequest` for a `Resource<A>`
    ///
    /// - Returns: A `URLRequest` for this resource
    public func requestWith<A>(_ resource: Resource<A>) throws -> URLRequest {
        
        // Set url
        guard let url = URL(string: basePath)?.appendingPathComponent(resource.urlPath) else {
            throw ResourceRequestConfigurationError.couldNotBuildUrl
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
        additionalHeaders?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        // Add Auth header
        if let credential = credential, let authAccessToken = credential.authAccessToken {
            request.addValue(authAccessToken, forHTTPHeaderField: credential.authHeaderKey)
        }
        
        return request
    }
}
