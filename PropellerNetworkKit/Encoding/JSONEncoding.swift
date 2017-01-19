//
//  JSONEncoding.swift
//  PropellerNetworkKit
//
//  Created by Roy McKenzie on 1/18/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

struct JSONEncoding: ParameterEncoding {
    public static var `default`: JSONEncoding = JSONEncoding()
    
    func encode(_ request: URLRequest, parameters: Parameters) throws -> URLRequest {
        var request = request
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            throw ParameterEncodingError.parameterEncodingFailed(error: error)
        }
        return request
    }
}
