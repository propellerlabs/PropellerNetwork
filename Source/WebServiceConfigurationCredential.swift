//
//  WebServiceConfigurationCredential.swift
//  PropellerNetwork
//
//  Created by Roy McKenzie on 1/23/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

private let APICredentialsAccessTokenKey = "APICredentialsAccessTokenKey"

/// Handles storing of the authentication token required for 
/// authorized resources
public struct WebServiceConfigurationCredential {
    /// The key for the authorization header
    public let authHeaderKey: String
    
    /// Access token for resource
    public var authAccessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: APICredentialsAccessTokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: APICredentialsAccessTokenKey)
        }
    }
    
    /// Initialize with a value for what the KEY value for the auth header should be
    /// - Parameters:
    ///     - authHeaderKey: The key for the authorization header
    public init(authHeaderKey: String) {
        self.authHeaderKey = authHeaderKey
    }
}
