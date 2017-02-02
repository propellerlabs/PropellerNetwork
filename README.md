![Travis](https://api.travis-ci.org/propellerlabs/PropellerNetwork.svg?branch=master)
![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)
![Swift](https://img.shields.io/badge/language-swift-orange.svg)
![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)
![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)
![MIT License](https://img.shields.io/badge/license-MIT-000000.svg)


# PropellerNetwork
Networking layer for Propeller iOS projects

## Installation

### Swift Package Manager

```Swift
dependencies: [
    .Package(url: "https://github.com/propellerlabs/PropellerNetwork.git", majorVersion: 1)
]
```

### Carthage

```
github "propellerlabs/PropellerNetwork"
```

## Usage

### Create a WebServiceConfiguration
A `WebServiceConfiguration` is passed into a `Resource` to let the `WebService` know how to configure the `URLRequest`. You can use a `WebServiceConfiguration` on multiple `Resource` objects.

#### Example

``` Swift
struct NetworkConfiguration {
    static let `default` = WebServiceConfiguration(basePath: "https://httpbin.org",
                                                   additionalHeaders: nil,
                                                   credential: nil)
}
```

### Create a resource
A resource encapsulates the expected return type, web service configuration, URL path, HTTP method, parameters, headers, encoding and parsing to handle the specific network request.

``` Swift
init(configuration: WebServiceConfiguration,
     urlPath: String,
     method: PropellerNetwork.HTTPMethod = .get,
     parameters: Parameters? = nil, 
     headers: [String : String]? = nil, 
     encoding: ParameterEncoding = JSONEncoder.default, 
     parsing: ((JSONObject) -> A?)? = nil)
```

#### Example
```Swift
struct User {
    let name: String    
}

let getUserResource = Resource<User>(configuration: NetworkConfiguration.default,
                                     urlPath: "/get",
                                     parsing: { json in
                                        guard let name = json["name"] as? String else {
                                            return nil
                                        }
                                        return User(name: name)
                                    })
```

### Request a resource
After setting up your resource, request it!

```Swift
WebService.request<A>(_ resource: Resource<A>, completion: @escaping (A?, Error?) -> Void)
```

####Example
```Swift
WebService.request(getUserResource) { object, error in
    print(object)
    print(error)
}
```

## Thanks

Special thanks to Chris Eidhof and Florian Kugler for their web episode [Swift Talk on Networking](https://talk.objc.io/episodes/S01E01-networking) as the inspiration for this project.
