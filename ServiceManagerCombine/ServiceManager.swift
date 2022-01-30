import Combine

public class ServiceManager: NSObject {
    
    private let apiService: NetworkService
    var apiQueue = DispatchQueue(label: "com.servicemanager.request", qos: .background, attributes: .concurrent)
    @available(iOS 13.0, *)
    private(set) lazy var cancellables = Set<AnyCancellable>()
    
    public override init() {
        self.apiService = NetworkHandler()
        super.init()
    }
    
    @available(iOS 13.0, *)
    private func fetch<Model: Decodable>(network: Future<Model, Error>) -> Future<Model, Error> {
        
        return Future<Model, Error> { [weak self] promise in
            guard let strongSelf = self else { return }
            network
                .subscribe(on: strongSelf.apiQueue)
                .sink(receiveCompletion: { (completion) in
                    if case let .failure(error) = completion {
                        promise(.failure(error))
                    }
                }, receiveValue: { value in
                    promise(.success(value))
                }).store(in: &strongSelf.cancellables)
        }
    }
}

extension ServiceManager: ServiceManagerType {
    
    @available(iOS 13.0, *)
    public func serviceCall<T: Decodable>(apiRequest: RequestModel) -> Future<T, Error> {
        return fetch(network: apiService.serviceCall(apiRequest: apiRequest))
    }
}
