//
//  RequestCredentialingTests.swift
//  PropellerNetwork
//
//  Created by Roy McKenzie on 2/10/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import XCTest
@testable import PropellerNetwork

class RequestCredentialingTests: XCTestCase {
    
    func testHeaderRequestCredentialer() {
        
        let configuration = ResourceConfiguration.headerCredentialed
        let getVoidResource = Resource<Void>(configuration: configuration, urlPath: "/get")
        
        guard let authKey = configuration.credential?.authKey else {
            XCTFail("No auth Key for credential")
            return
        }
        
        var authToken: String?
        
        do {
            let request = try WebService.urlRequestWith(getVoidResource)
            authToken = request.value(forHTTPHeaderField: authKey)
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
        
        XCTAssertNotNil(authToken)
    }

    func testQueryStringRequestCredentialer() {
        
        let configuration = ResourceConfiguration.queryCredentialed
        let getVoidResource = Resource<Void>(configuration: configuration, urlPath: "/get")
        
        guard let authKey = configuration.credential?.authKey else {
            XCTFail("No auth Key for credential")
            return
        }
        
        var authToken: String?
        
        do {
            let request = try WebService.urlRequestWith(getVoidResource)
            let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            components?.queryItems?.forEach { item in
                print(item)
                if item.name == authKey {
                    authToken = item.value
                }
            }
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
        
        XCTAssertNotNil(authToken)
    }

}
