//
//  QueryStringEncoder.swift
//  PropellerNetwork
//
//  Created by Roy McKenzie on 1/18/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

public struct QueryStringEncoder: ParameterEncoding {
    public static var `default`: QueryStringEncoder = QueryStringEncoder()
    
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
