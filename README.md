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

#### Example
```Swift
  resource.request { object, error in
      print(object)
      print(error)
  }
```

##Thanks

Special thanks to Chris Eidhof and Florian Kugler for their [Swift Talk web episode on Networking](https://talk.objc.io/episodes/S01E01-networking) as the inspiration for this project.
