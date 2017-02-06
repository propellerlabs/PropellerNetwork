//
//  QueryStringEncoder.swift
//  PropellerNetwork
//
//  Created by Roy McKenzie on 1/18/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

/// Handles appending key-value paris to a `URLRequest`'s `URL` object
public struct QueryStringEncoder: ParameterEncoding {
    /// Static accessible implementation
    public static var `default`: QueryStringEncoder = QueryStringEncoder()
    
    /// Adds parameters to a `URLRequest` body
    /// - Parameters:
    ///     - request: `URLRequest` object to encode parameters onto
    ///     - parameters: dictionary of key-value pairs to add to `URLRequest`
    /// - Returns: `URLRequest`
    public func encode(_ request: URLRequest, parameters: Parameters) throws -> URLRequest {
        var request = request
        
        let queryItems = parameters.flatMap { URLQueryItem(name: $0.key, value: "\($0.value)") }
        
        if let url = request.url {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            request.url = components?.url
        }
        return request
    }
}
