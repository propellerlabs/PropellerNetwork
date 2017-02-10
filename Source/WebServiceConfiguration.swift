//
//  WebServiceConfiguration.swift
//  PropellerNetwork
//
//  Created by Roy McKenzie on 1/18/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

public enum WebServiceConfigurationError: Error {
    case couldNotBuildUrl
}

extension WebServiceConfigurationError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .couldNotBuildUrl:
            return NSLocalizedString("Could not build URL", comment: "")
        }
    }
}

/// Protocol for configuring a `URLRequest` for a resource credentials on a request
public struct WebServiceConfiguration {
    public let basePath: String?
    public let additionalHeaders: [String: String]?
    public var credential: WebServiceConfigurationCredential?
    
    public init(basePath: String?,
         additionalHeaders: [String: String]?,
         credential: WebServiceConfigurationCredential?) {
        
        self.basePath = basePath
        self.additionalHeaders = additionalHeaders
        self.credential = credential
    }
}
