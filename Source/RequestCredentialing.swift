//
//  RequestCredentialing.swift
//  PropellerNetwork
//
//  Created by Roy McKenzie on 2/10/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

/// Protocol that applies a credential to a `URLRequest`
public protocol RequestCredentialing {
    /// Authorization key for a request
    var authKey: String { get set }
    /// authorization token for a request
    var authToken: String? { get set }
    /// Applies a credential to a request
    ///
    /// - Parameters:
    ///     - request: The `URLRequest` to credential
    /// - Returns: A credentialed `URLRequest`
    func applyTo(_ request: URLRequest) -> URLRequest
}
