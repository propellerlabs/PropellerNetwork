//
//  JSONEncoding.swift
//  PropellerNetworkKit
//
//  Created by Roy McKenzie on 1/18/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

enum JSONEncodingError: Error {
    case notValidJSON
}

struct JSONEncoding: ParameterEncoding {
    public static var `default`: JSONEncoding = JSONEncoding()
    
    func encode(_ request: URLRequest, parameters: Parameters) throws -> URLRequest {
        var request = request
        
        // Make sure object is valid JSON
        if !JSONSerialization.isValidJSONObject(parameters) {
            throw JSONEncodingError.notValidJSON
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
