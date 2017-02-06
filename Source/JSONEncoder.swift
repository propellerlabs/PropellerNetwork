//
//  JSONEncoder.swift
//  PropellerNetwork
//
//  Created by Roy McKenzie on 1/18/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

public enum JSONEncoderError: Error {
    /// Foundation object passed to encoder is not a valid JSON object
    case notValidJSON
}

/// Handles converting a JSON object into data for transmission in 
/// `URLRequest`
public struct JSONEncoder: ParameterEncoding {
    /// Static accessible implementation with no `JSONSerialization` options
    public static var `default`: JSONEncoder = JSONEncoder()
    
    /// Adds parameters to a `URLRequest` body
    /// - Parameters:
    ///     - request: `URLRequest` object to encode parameters onto
    ///     - parameters: dictionary of key-value pairs to add to `URLRequest`
    /// - Returns: `URLRequest`
    public func encode(_ request: URLRequest, parameters: Parameters) throws -> URLRequest {
        var request = request
        
        // Make sure object is valid JSON
        if !JSONSerialization.isValidJSONObject(parameters) {
            throw JSONEncoderError.notValidJSON
        }
        
        // Encode foundation object to data and set to request body
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            throw error
        }
        
        // Since this is JSON, set the headers to tell the server to expect JSON
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // Return modified request
        return request
    }
}
