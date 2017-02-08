//
//  JSONDecoder.swift
//  PropellerNetwork
//
//  Created by Roy McKenzie on 1/23/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

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
    public static func decode(_ data: Data) throws -> Any {
        
        let jsonObject: Any
        
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            throw error
        }
        
        return jsonObject
    }
}
