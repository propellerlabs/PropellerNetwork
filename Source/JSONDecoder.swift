//
//  JSONDecoder.swift
//  PropellerNetwork
//
//  Created by Roy McKenzie on 1/23/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

enum JSONDecoderError: Error {
    case objectNotJSONObject
}

/// Handles decoding Data into a Foundation object
public struct JSONDecoder {

    /// Decodes `Data` into a `JSONObject`.
    ///
    /// - Note: if `JSONSerialization` returns a top level
    ///   array then we wrap it in a dictionary.
    ///
    /// - Parameters: 
    ///     - data: `Data` object to be converted to `JSONObject`
    /// - Returns: `JSONObject`
    public static func decode(_ data: Data) throws -> JSONObject {
        
        var jsonObjectAny: Any
        
        do {
            jsonObjectAny = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            throw error
        }
        
        // If object is a top level array then create a dictionary with empty dictionary key
        if jsonObjectAny is [JSONObject] {
            jsonObjectAny = ["": jsonObjectAny]
        }
        
        // Cast as a JSONObject [String: Any]
        guard let jsonObject = jsonObjectAny as? JSONObject else {
            throw JSONDecoderError.objectNotJSONObject
        }
        
        return jsonObject
    }
}
