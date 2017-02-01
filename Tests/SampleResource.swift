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
    
    public static func create(name: String, email: String, password: String) -> Resource<User> {
        let params = [
            "name": name,
            "email": email,
            "password": password
        ]
        return Resource<User>(urlPath: "/post", method: .post, parameters: params) { json in
            guard let jsonData = json["json"] as? JSONObject else {
                return nil
            }
            guard let name = jsonData["name"] as? String, let email = jsonData["email"] as? String else {
                return nil
            }
            return User(name: name, email: email)
        }
    }
}
