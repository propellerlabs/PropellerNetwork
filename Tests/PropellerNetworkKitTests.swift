//
//  PropellerNetworkTests.swift
//  PropellerNetworkTests
//
//  Created by Roy McKenzie on 1/18/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import XCTest
@testable import PropellerNetwork

let timeout: TimeInterval = 10 //seconds for timeout

class PropellerNetworkTests: XCTestCase {
    
    func testResourceParseSuccessful() {
        
        let resource = User.create(name: "Tester", email: "tester@propellerlabs.co", password: "test")
        
        let expectation = self.expectation(description: "Resource should return completion")
        
        var requestError: Error?
        var requestUser: User?
        
        resource.request(configuration: TestResourceRequestConfiguration.default) { user, error in
            requestError = error
            requestUser = user
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertNotNil(requestUser)
        XCTAssertNil(requestError)
    }
    
    func testVoidResourceParseSuccessful() {
        
        let resource = Resource<Void>(urlPath: "/get")
        
        let expectation = self.expectation(description: "Resource should return completion")
        
        var requestError: Error?
        
        resource.request(configuration: TestResourceRequestConfiguration.default) { void, error in
            requestError = error
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertNil(requestError)
    }
    
    func testRequestWithAdditionalHeaders() {
        
        let headers = [
            "ExtraHeaderKey": "ExtraHeaderValue"
        ]
        
        let resource = Resource<Void>(urlPath: "/get", headers: headers)
        
        var requestError: Error?
        
        do {
            let request = try TestResourceRequestConfiguration.default.requestWith(resource)
            let headerValue = request.value(forHTTPHeaderField: "ExtraHeaderKey")
            
            XCTAssertTrue(headerValue == "ExtraHeaderValue")
        } catch {
            requestError = error
        }
        
        XCTAssertNil(requestError)
    }
    
    func testQueryStringParameterEncoding() {
        
        let params = [
            "includes_images": true
        ]
        
        let resource = Resource<Void>(urlPath: "/get", parameters: params, encoding: QueryStringEncoder.default)
        
        var encodingError: Error?
        
        do {
            let request = try TestResourceRequestConfiguration.default.requestWith(resource)
            
            guard let url = request.url else {
                XCTFail("URL is nil")
                return
            }
            
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            
            guard let queries = components?.queryItems else {
                XCTFail("No query items")
                return
            }
            
            let query = queries.first(where: { $0.name == "includes_images" })
            
            XCTAssertNotNil(query)
        } catch {
            encodingError = error
        }
        
        XCTAssertNil(encodingError)
    }
    
    func testResourceWithMalformedURLBasePath() {
        
        let resource = Resource<Void>(urlPath: "/get")
        
        var configurationError: Error?
        
        do {
            let _ = try TestFailingResourceRequestConfiguration.default.requestWith(resource)
        } catch {
            configurationError = error
        }
        
        XCTAssertNotNil(configurationError)
        
        if let error = configurationError as? ResourceRequestConfigurationError {
            XCTAssertTrue(error == .couldNotBuildUrl)
        } else {
            XCTFail("Unexpected Error type")
        }
    }
    
    func testFailingResourceConfigurationRequest() {
        
        let resource = Resource<Void>(urlPath: "/get")
        
        var requestError: Error?
        
        let expectation = self.expectation(description: "Resource should return completion")

        resource.request(configuration: TestFailingResourceRequestConfiguration.default) { _, error in
            requestError = error
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertNotNil(requestError)
        
        if let error = requestError as? ResourceRequestConfigurationError {
            XCTAssertTrue(error == .couldNotBuildUrl)
        } else {
            XCTFail("Unexpected Error type")
        }
    }
    
    func testFailingJSONDecoding() {
        
        let resource = Resource<Bool>(urlPath: "/xml") { _ in
            return true
        }
        
        let expectation = self.expectation(description: "Resource should return completion")
        
        var requestError: Error?
        
        resource.request(configuration: TestResourceRequestConfiguration.default) { _, error in
            requestError = error
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertNotNil(requestError)
    }
    
    func testFailingInvalidJSONEncoding() {
        
        let parameters = [
            "date": Date()
        ]
        
        var encodingError: Error?
        
        let request = URLRequest(url: URL(string: "http://www.google.com")!)
        
        do {
            let _ = try JSONEncoder.default.encode(request, parameters: parameters)
        } catch {
            encodingError = error
        }
        
        XCTAssertNotNil(encodingError)
        
        if let error = encodingError as? JSONEncoderError {
            XCTAssertTrue(error == JSONEncoderError.notValidJSON)
        } else {
            XCTFail("Unexpected Error type")
        }
    }
    
    func testFailingResponseStatusCode() {
        
        let resource = Resource<Void>(urlPath: "/status/404")
        
        let expectation = self.expectation(description: "Resource should return completion")
        
        var requestError: Error?
        
        resource.request(configuration: TestResourceRequestConfiguration.default) { void, error in
            requestError = error
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertNotNil(requestError)
        
        if let error = requestError as? WebServiceError {
            switch error {
            case .unacceptableStatusCode:
                break
            default:
                XCTFail("Unexpected error type")
            }
        }
    }
    
    func testFailingRequestWithError() {
        
        let resource = Resource<Bool>(urlPath: "notAValidUrlPath")
        
        let expectation = self.expectation(description: "Resource should return completion")
        
        var requestError: Error?
        
        resource.request(configuration: TestErrorResourceRequestConfiguration.default) { _, error in
            requestError = error
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertNotNil(requestError)
        
        if let _ = requestError as? URLError {
            XCTAssert(true)
        } else {
            XCTFail("Unexpected error type")
        }
    }
    
    func testFailingRequestWithJSONSerializationError() {
        
        let resource = Resource<Bool>(urlPath: "bytes/0")
        
        let expectation = self.expectation(description: "Resource should return completion")
        
        var requestError: Error?
        
        resource.request(configuration: TestResourceRequestConfiguration.default) { void, error in
            requestError = error
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertNotNil(requestError)
    }
}

/// Network configuration for testing
struct TestResourceRequestConfiguration: ResourceRequestConfiguring {
    let basePath: String
    let additionalHeaders: [String : String]?
    var credential: ResourceRequestCredential?
    
    static var `default`: TestResourceRequestConfiguration {
        let additionalHeaders = ["Content-Type": "application/json"]
        var credential = ResourceRequestCredential(authHeaderKey: "Authorization")
        credential.authAccessToken = "TestAccessToken"
        return TestResourceRequestConfiguration(basePath: "https://httpbin.org",
                                                additionalHeaders: additionalHeaders,
                                                credential: credential)
    }
}

/// Network configuration for testing invalid base path
struct TestFailingResourceRequestConfiguration: ResourceRequestConfiguring {
    let basePath: String
    let additionalHeaders: [String : String]?
    var credential: ResourceRequestCredential?
    
    static var `default`: TestFailingResourceRequestConfiguration {
        let additionalHeaders = ["Content-Type": "application/json"]
        var credential = ResourceRequestCredential(authHeaderKey: "Authorization")
        credential.authAccessToken = "TestAccessToken"
        return TestFailingResourceRequestConfiguration(basePath: "Not a url",
                                                       additionalHeaders: additionalHeaders,
                                                       credential: credential)
    }
}

/// Network configuration for testing invalid responses
struct TestErrorResourceRequestConfiguration: ResourceRequestConfiguring {
    let basePath: String
    let additionalHeaders: [String : String]?
    var credential: ResourceRequestCredential?
    
    static var `default`: TestErrorResourceRequestConfiguration {
        let additionalHeaders = ["Content-Type": "application/json"]
        var credential = ResourceRequestCredential(authHeaderKey: "Authorization")
        credential.authAccessToken = "TestAccessToken"
        return TestErrorResourceRequestConfiguration(basePath: "http://abcd.1234567.coo",
                                                       additionalHeaders: additionalHeaders,
                                                       credential: credential)
    }
}
