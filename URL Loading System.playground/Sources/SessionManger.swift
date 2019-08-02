import Foundation

public final class SessionManager {
    
    public let session: URLSession
    
    public let sessionDelegate: SessionDelagate
    
    public init(configuration: URLSessionConfiguration, delegate: SessionDelagate) {
        self.sessionDelegate = delegate
        self.session = URLSession(
            configuration: configuration,
            delegate: sessionDelegate,
            delegateQueue: sessionDelegate.operationQueue)
    }
    
    public func dataRequest(with urlRequest: URLRequest) -> DataRequest {
        let dataTask = session.dataTask(with: urlRequest)
        let dataRequest = DataRequest(dataTask: dataTask)
        
        sessionDelegate.setDelagate(dataRequest, for: dataTask)
        
        return dataRequest
    }
}
