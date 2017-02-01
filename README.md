![Travis](https://api.travis-ci.org/propellerlabs/PropellerNetwork.svg?branch=master)
![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)
![Swift](https://img.shields.io/badge/language-swift-orange.svg)
![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)
![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)
![MIT License](https://img.shields.io/badge/license-MIT-000000.svg)


# PropellerNetwork
Networking layer for Propeller iOS projects

## Installation

## Swift Package Manager

```Swift
dependencies: [
.Package(url: "https://github.com/propellerlabs/PropellerNetwork.git", majorVersion: 1)
]
```

## Usage

### Create a resource request configuration
A resource request configuration should conform to `ResourceRequestConfiguring`. This will provide the networking layer with the basics about each network request to make

#### Example

``` Swift
struct NetworkConfiguration: ResourceRequestConfiguring {
static let `default` = NetworkConfiguration()

var basePath: String {
return "https://httpbin.org"
}

var additionalHeaders: [String : String]? {
return nil
}

var credential: ResourceRequestCredential? {
return nil
}
}
```

### Create a resource
A resource encapsulates the expected return type, URL path, HTTP method, parameters, headers, encoding and parsing to handle the specific network request.

``` Swift
init(urlPath: String, 
method: PropellerNetwork.HTTPMethod = .get, 
parameters: Parameters? = nil, 
headers: [String : String]? = nil, 
encoding: ParameterEncoding = JSONEncoder.default, 
parsing: ((JSONObject) -> A?)? = nil)
```

#### Example
```Swift
let resource = Resource<T>(urlPath: "/get",
parsing: { json in
// Parse JSON to your object `T`
})
```

### Request a resource
After setting up your resource, request it!

```Swift
request(completion: (T?, Error?) -> Void)
```

####Example
```Swift
resource.request { object, error in
print(object)
print(error)
}
```
