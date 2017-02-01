//
//  ResourceRequestCredential.swift
//  PropellerNetwork
//
//  Created by Roy McKenzie on 1/23/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

private let APICredentialsAccessTokenKey = "APICredentialsAccessTokenKey"
public struct ResourceRequestCredential {
    /// The key for the authorization header
    let authHeaderKey: String
    
    /// Access token for resource
    var authAccessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: APICredentialsAccessTokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: APICredentialsAccessTokenKey)
        }
    }
}
