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

/// Protocol for configuring a `URLRequest` for a resource credentials on a request
public struct WebServiceConfiguration {
    let basePath: String
    let additionalHeaders: [String: String]?
    var credential: WebServiceConfigurationCredential?
}
