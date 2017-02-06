//
//  ParameterEncoding.swift
//  PropellerNetwork
//
//  Created by Roy McKenzie on 1/18/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

/// Protocol that all `URLRequest` parameter encoders conform to
public protocol ParameterEncoding {
    
    /// Encode a request with parameters
    ///
    /// - Parameters:
    ///     - request: The request to modify
    ///     - parameters: The parameters to appy to the request
    func encode(_ request: URLRequest, parameters: Parameters) throws -> URLRequest
}
