//
//  QueryStringRequestCredential.swift
//  PropellerNetwork
//
//  Created by Roy McKenzie on 2/10/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

/// A request credentialer that applies credentials to a `URLRequest`
/// on the request `URL`'s query string
public struct QueryStringRequestCredential: RequestCredentialing {
    /// query string auth key
    public var authKey: String
    /// query string auth token
    public var authToken: String?
    
    /// Apply credential to `URLRequest` `URL`
    ///
    /// - Parameters: 
    ///     - request: The `URLRequest` to credential
    /// - Returns: A credentialed `URLRequest`
    public func applyTo(_ request: URLRequest) -> URLRequest {
        var request = request
        
        if let authToken = authToken {
            let authParameters = [
                authKey: authToken
            ]
            if let authorizedRequest = try? QueryStringEncoder.default.encode(request,
                                                                              parameters: authParameters) {
                request = authorizedRequest
            }
        }
        
        return request
    }
}
