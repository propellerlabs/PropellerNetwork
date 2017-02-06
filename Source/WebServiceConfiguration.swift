//
//  WebServiceConfiguration.swift
//  PropellerNetwork
//
//  Created by Roy McKenzie on 1/18/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

/// Error type that holds cases for when configuring a `WebService` request fails
public enum WebServiceConfigurationError: Error {
    /// Could not build `URL` for a `URLRequest`
    case couldNotBuildUrl
}

/// A configuration object used for configuring a `URLRequest` for a resource
public struct WebServiceConfiguration {
    /// Ex. "http://httpbin.org"
    public let basePath: String
    /// Additonal headers as required by server you are connecting to
    public let additionalHeaders: [String: String]?
    /// A `WebServiceConfigurationCredential` object that handles storing of the 
    /// authentication token required for authorized resources
    public var credential: WebServiceConfigurationCredential?
    
    /// - Parameters:
    ///     - basePath: Ex. "http://httpbin.org"
    ///     - additionalHeaders: Additonal headers as required by server you are connecting to
    ///     - credential: A `WebServiceConfigurationCredential` object that handles storing of the authentication token required for authorized resources
    public init(basePath: String,
         additionalHeaders: [String: String]?,
         credential: WebServiceConfigurationCredential?) {
        
        self.basePath = basePath
        self.additionalHeaders = additionalHeaders
        self.credential = credential
    }
}
