//
//  ParameterEncoding.swift
//  PropellerNetworkKit
//
//  Created by Roy McKenzie on 1/18/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

/// Error types for parameter encoding
enum ParameterEncodingError: Error {
    case parameterEncodingFailed(error: Error)
}

/// Protocol that all URLRequest paramter encoders conform to
protocol ParameterEncoding {
    
    /// Encode a request with parameters
    ///
    /// - Parameters:
    ///     - request: The request to modify
    ///     - parameters: The parameters to appy to the request
    func encode(_ request: URLRequest, parameters: Parameters) throws -> URLRequest
}
