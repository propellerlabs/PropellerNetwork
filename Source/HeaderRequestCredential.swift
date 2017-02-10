//
//  HeaderRequestCredential.swift
//  PropellerNetwork
//
//  Created by Roy McKenzie on 1/23/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

/// A request credentialer that applies credentials to a `URLRequest`
/// on the request's header
public struct HeaderRequestCredential: RequestCredentialing {
    /// Header auth key
    public var authKey: String
    /// Header auth token
    public var authToken: String?
    
    public init(authKey: String, authToken: String? = nil) {
        self.authKey = authKey
        self.authToken = authToken
    }
    
    /// Apply credential to request header
    ///
    /// - Parameters:
    ///     - request: The `URLRequest` to credential
    /// - Returns: A credentialed `URLRequest`
    public func applyTo(_ request: URLRequest) -> URLRequest {
        var request = request
        if let authToken = authToken {
            request.addValue(authToken, forHTTPHeaderField: authKey)
        }
        return request
    }
}
