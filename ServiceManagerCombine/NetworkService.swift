import Combine

protocol NetworkService {
    
    @available(iOS 13.0, *)
    func serviceCall<T: Decodable>(apiRequest: RequestModel) -> Future<T, Error>
}
