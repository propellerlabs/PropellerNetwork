//
//  SampleResource.swift
//  PropellerNetwork
//
//  Created by Roy McKenzie on 1/23/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation
@testable import PropellerNetwork

struct User {
    let name: String
    let email: String
}

extension User {
    
    public static func create(name: String,
                              email: String,
                              password: String) -> Resource<User> {
        let params = [
            "name": name,
            "email": email,
            "password": password
        ]
        return Resource<User>(configuration: ResourceConfiguration.default,
                              urlPath: "/post",
                              method: .post,
                              parameters: params) { json in

            guard let json = json as? JSONObject else {
                return nil
            }
            guard let jsonData = json["json"] as? JSONObject else {
                return nil
            }
            guard let name = jsonData["name"] as? String,
                let email = jsonData["email"] as? String else {
                return nil
            }
            return User(name: name, email: email)
        }
    }
}

struct Pokemon {
    
    public static func get() -> Resource<Void> {
        return Resource<Void>(configuration: ResourceConfiguration.emptyBase, urlPath: "http://pokeapi.co/api/v2/pokemon/4/")
    }
    
    public static func getFullPathBase() -> Resource<Void> {
        return Resource<Void>(configuration: ResourceConfiguration.fullPathBase, urlPath: "")
    }
}

/// Network configuration for testing
struct ResourceConfiguration {
    
    //. Default successful configuration
    static var `default`: WebServiceConfiguration = {
        let additionalHeaders = ["Content-Type": "application/json"]
        var credential = WebServiceConfigurationCredential(authHeaderKey: "Authorization")
        credential.authAccessToken = "TestAccessToken"
        return WebServiceConfiguration(basePath: "https://httpbin.org",
                                       additionalHeaders: additionalHeaders,
                                       credential: credential)
    }()

    /// Network configuration for testing invalid base path
    static var failing: WebServiceConfiguration = {
        let additionalHeaders = ["Content-Type": "application/json"]
        var credential = WebServiceConfigurationCredential(authHeaderKey: "Authorization")
        credential.authAccessToken = "TestAccessToken"
        return WebServiceConfiguration(basePath: "Not a url",
                                       additionalHeaders: additionalHeaders,
                                       credential: credential)
    }()

    /// Network configuration for testing invalid responses
    static var error: WebServiceConfiguration = {
        let additionalHeaders = ["Content-Type": "application/json"]
        var credential = WebServiceConfigurationCredential(authHeaderKey: "Authorization")
        credential.authAccessToken = "TestAccessToken"
        return WebServiceConfiguration(basePath: "http://abcd.1234567.coo",
                                       additionalHeaders: additionalHeaders,
                                       credential: credential)
    }()
    
    /// Network configuration for testing invalid responses
    static var emptyBase: WebServiceConfiguration = {
        return WebServiceConfiguration(basePath: "",
                                       additionalHeaders: nil,
                                       credential: nil)
    }()
    
    static var fullPathBase: WebServiceConfiguration = {
        return WebServiceConfiguration(basePath: "http://pokeapi.co/api/v2/pokemon/4/",
                                       additionalHeaders: nil,
                                       credential: nil)
    }()
}
