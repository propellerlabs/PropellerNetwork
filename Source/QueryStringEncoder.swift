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
        
        var queryItems = parameters.flatMap {
            URLQueryItem(name: $0.key, value: "\($0.value)")
        }
        
        if let url = request.url {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            
            let baseString = url.absoluteString
            
            if let currentQueryItems = components?.queryItems {
                queryItems.append(contentsOf: currentQueryItems)
            }
            
            components?.queryItems = queryItems
            
            if let queryString = components?.query {
                let newUrl = URL(string: "\(baseString)?\(queryString)")
                request.url = newUrl
            }
        }
        
        return request
    }
    
    public func escape(_ string: String) -> String {
        var allowedCharacters = NSCharacterSet.urlQueryAllowed
        allowedCharacters.remove(charactersIn: "+@")
        let newString = string.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
        return newString ?? string
    }
}
