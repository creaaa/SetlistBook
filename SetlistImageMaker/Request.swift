/*
struct Request {
    
    struct RateLimitRequest: Request {
        typealias Response = RateLimit
        
        var baseURL: URL {
            return URL(string: "https://api.github.com")!
        }
        
        var method: HTTPMethod {
            return .get
        }
        
        var path: String {
            return "/rate_limit"
        }
        
        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> RateLimit {
            return try RateLimit(object: object)
        }
    }
    
}
*/
