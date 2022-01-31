import Combine
public let k_DEFAULT_REQUEST_TIMEOUT = 180.0
public let k_DEFAULT_RESOURCE_TIMEOUT = 180.0

class NetworkHandler {
    
    fileprivate enum ApiError: Error {
        case DataNotFound
        case serverFailure
    }
    @available(iOS 13.0, *)
    private(set) lazy var cancellables = Set<AnyCancellable>()
    
    @available(iOS 13.0, *)
    func sender<T: Decodable>(apiRequest: RequestModel) -> Future<T, Error> {
        return Future<T, Error> { [weak self] promise in
            guard let strongSelf = self else { return }
            strongSelf.debugPrintRequest(apiRequest: apiRequest)
            let request = apiRequest.request()
            
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
            sessionConfig.timeoutIntervalForRequest = k_DEFAULT_REQUEST_TIMEOUT
            sessionConfig.timeoutIntervalForResource = k_DEFAULT_RESOURCE_TIMEOUT
            let session = URLSession(configuration: sessionConfig)
            
            defer {
                session.finishTasksAndInvalidate()
            }
            
            session.dataTaskPublisher(for: request)
                .tryMap { (data, response) in
                    if let httpResponse = response as? HTTPURLResponse {
                        if 200 ..< 300 ~= httpResponse.statusCode {
                            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                            strongSelf.debugPrintResponse(Type: T.self, dict: responseJSON as? [String:Any] ?? [:])
                            return data
                            
                        } else {
                            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                            strongSelf.debugPrintResponse(Type: T.self, dict: responseJSON as? [String:Any] ?? [:])
                            throw NSError(domain:apiRequest.path, code:httpResponse.statusCode, userInfo:responseJSON as? [String : Any])
                            
                        }
                    } else {
                        return data
                    }
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .sink(receiveCompletion: { (completion) in
                    if case let .failure(error) = completion {
                        promise(.failure(error))
                    }
                }, receiveValue: { value in
                    promise(.success(value))
                })
                .store(in: &strongSelf.cancellables)
        }
    }
    
    func convertDictToJSON(dict: [String:Any]) -> NSString {
        let jsonbody = try! JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
        return NSString(data: jsonbody, encoding: String.Encoding.utf8.rawValue) ?? ""
    }
    
    fileprivate func debugPrintResponse<T: Decodable>(Type: T.Type, dict: [String:Any]) {
        debugPrint("Response of \(Type.self):", self.convertDictToJSON(dict: dict))
    }
    
    fileprivate func convertMutableDataToJSON(model: NSMutableData) -> NSString {
        return NSString(data: model as Data, encoding: String.Encoding.utf8.rawValue) ?? ""
    }
    
    fileprivate func debugPrintRequest(apiRequest: RequestModel) {
        
        debugPrint("URL: ", apiRequest.url.description)
        
        debugPrint("Path: ", apiRequest.path)
        
        debugPrint("Method: ", apiRequest.method)
        
        if let header = apiRequest.header {
            debugPrint("Header: ",self.convertDictToJSON(dict: header))
        }
        
        if let body = apiRequest.bodyParameters {
            debugPrint("Post Body: ",self.convertDictToJSON(dict: body))
        }
        
        if let getBody = apiRequest.getRequestParameters {
            debugPrint("Get Body: ", self.convertDictToJSON(dict: getBody))
        }
        
        if let getBody = apiRequest.multipartFormDataRequest {
            debugPrint("Multipart Body: ", self.convertMutableDataToJSON(model: getBody.body))
        }
    }
}

extension NetworkHandler: NetworkService {
    
    @available(iOS 13.0, *)
    func serviceCall<T: Decodable>(apiRequest: RequestModel) -> Future<T, Error> {
        return sender(apiRequest: apiRequest)
    }
}

public extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
    var userInfo: [String : Any] { return (self as NSError).userInfo }
}

