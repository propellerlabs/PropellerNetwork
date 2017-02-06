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
        
        let userResource = User.create(name: "Tester", email: "tester@propellerlabs.co", password: "test")
        
        let expectation = self.expectation(description: "Resource should return completion")
        
        var requestError: Error?
        var requestUser: User?
        
        WebService.request(userResource) { user, error in
            requestError = error
            requestUser = user
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertNotNil(requestUser)
        XCTAssertNil(requestError)
    }
    
    func testVoidResourceParseSuccessful() {
        
        let getVoidResource = Resource<Void>(configuration: ResourceConfiguration.default, urlPath: "/get")
        
        let expectation = self.expectation(description: "Resource should return completion")
        
        var requestError: Error?
        
        WebService.request(getVoidResource) { void, error in
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
        
        let getVoidResource = Resource<Void>(configuration: ResourceConfiguration.default, urlPath: "/get", headers: headers)
        
        var requestError: Error?
        
        do {
            let request = try WebService.urlRequestWith(getVoidResource)
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
        
        let getVoidResource = Resource<Void>(configuration: ResourceConfiguration.default, urlPath: "/get", parameters: params, encoding: QueryStringEncoder.default)
        
        var encodingError: Error?
        
        do {
            let request = try WebService.urlRequestWith(getVoidResource)
            
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
        
        let getVoidResource = Resource<Void>(configuration: ResourceConfiguration.failing, urlPath: "/get")
        
        var configurationError: Error?
        
        do {
            let _ = try WebService.urlRequestWith(getVoidResource)
        } catch {
            configurationError = error
        }
        
        XCTAssertNotNil(configurationError)
        
        if let error = configurationError as? WebServiceConfigurationError {
            XCTAssertTrue(error == .couldNotBuildUrl)
        } else {
            XCTFail("Unexpected Error type")
        }
    }
    
    func testFailingResourceConfigurationRequest() {
        
        let getVoidResource = Resource<Void>(configuration: ResourceConfiguration.failing, urlPath: "/get")
        
        var requestError: Error?
        
        let expectation = self.expectation(description: "Resource should return completion")

        WebService.request(getVoidResource) { _, error in
            requestError = error
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertNotNil(requestError)
        
        if let error = requestError as? WebServiceConfigurationError {
            XCTAssertTrue(error == .couldNotBuildUrl)
        } else {
            XCTFail("Unexpected Error type")
        }
    }
    
    func testFailingJSONDecoding() {
        
        let getXMLResource = Resource<Bool>(configuration: ResourceConfiguration.default, urlPath: "/xml") { _ in
            return true
        }
        
        let expectation = self.expectation(description: "Resource should return completion")
        
        var requestError: Error?
        
        WebService.request(getXMLResource) { _, error in
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
        
        let errorStatusCodeResource = Resource<Void>(configuration: ResourceConfiguration.default, urlPath: "/status/404")
        
        let expectation = self.expectation(description: "Resource should return completion")
        
        var requestError: Error?
        
        WebService.request(errorStatusCodeResource) { void, error in
            requestError = error
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertNotNil(requestError)
        
        if let error = requestError as? WebServiceRequestError {
            switch error {
            case .unacceptableStatusCode:
                break
            default:
                XCTFail("Unexpected error type")
            }
        }
    }
    
    func testFailingRequestWithError() {
        
        let invalidPathResource = Resource<Bool>(configuration: ResourceConfiguration.error, urlPath: "notAValidUrlPath")
        
        let expectation = self.expectation(description: "Resource should return completion")
        
        var requestError: Error?
        
        WebService.request(invalidPathResource) { _, error in
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
        
        let failingResource = Resource<Bool>(configuration: ResourceConfiguration.default, urlPath: "bytes/0")
        
        let expectation = self.expectation(description: "Resource should return completion")
        
        var requestError: Error?
        
        WebService.request(failingResource) { void, error in
            requestError = error
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertNotNil(requestError)
    }
    
    func testTopLevelArrayResponse() {
        
        let topLevelJsonArray = "[ { \"name\": \"roy\" }, { \"name\": \"rich\" } ]"
        
        guard let data = topLevelJsonArray.data(using: .utf8) else {
            XCTFail()
            return
        }
        
        do {
            let _ = try JSONDecoder.decode(data)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testNonTopLevelArrayResponse() {
        
        let nonTopLevelJsonArray = "{ \"values\": [{ \"name\": \"roy\" }, { \"name\": \"rich\" } ] }"
        
        guard let data = nonTopLevelJsonArray.data(using: .utf8) else {
            XCTFail()
            return
        }
        
        do {
            let _ = try JSONDecoder.decode(data)
        } catch {
            XCTAssertNil(error)
        }
    }
}
