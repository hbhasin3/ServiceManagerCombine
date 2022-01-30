import Foundation

public class RequestModel: ServiceRequest {
    
    
    public var url: URL
    public var method: String
    public var path: String
    public var getRequestParameters: [String : String]?
    public var bodyParameters: [String : Any]?
    public var header: [String : Any]?
    public var multipartFormDataRequest:  MultipartFormDataRequest? = nil
    
    public init(url: URL, path: String, method: String, header: [String:Any]?, bodyParameters: [String:Any]?, getRequestParameters: [String:String]?, multipartFormDataRequest:  MultipartFormDataRequest? = nil) {
        self.url = url
        self.bodyParameters = bodyParameters
        self.method = method
        self.path = path
        self.header = header
        self.getRequestParameters = getRequestParameters
        self.multipartFormDataRequest = multipartFormDataRequest
    }
    
    deinit {
        print("RequestModel Deinit")
    }
}
