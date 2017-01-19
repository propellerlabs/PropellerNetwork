//
//  RequestCredentialing.swift
//  PropellerNetworkKit
//
//  Created by Roy McKenzie on 1/18/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

/// Protocol for bestowing credentials on a request
protocol ResourceCredentialing {
    func credential<A>(_ resource: Resource<A>) throws -> URLRequest
}
