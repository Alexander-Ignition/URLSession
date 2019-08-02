import Foundation

public class Request: NSObject {

    // MARK: - Types
    
    public typealias AuthenticationChallengeResult = (
        _ disposition: URLSession.AuthChallengeDisposition,
        _ credentila: URLCredential?
        ) -> Void
    
    public typealias AuthenticationChallengeHandler = (
        _ session: URLSession,
        _ task: URLSessionTask,
        _ challenge: URLAuthenticationChallenge,
        _ completionHandler: AuthenticationChallengeResult
        ) -> Void
    
    
    public let task: URLSessionTask
    
    public init(task: URLSessionTask) {
        self.task = task
        super.init()
    }
    
    // MARK: - Properties
    
    public private(set) var isWaitingForConnectivity = false
    
    public var waitingForConnectivityHandler: (() -> Void)?
    
    public var authenticationChallengeHandler: AuthenticationChallengeHandler = {
        (_, _, _, completionHandler) in
        completionHandler(.performDefaultHandling, nil)
    }
    
    public private(set) var metrics = URLSessionTaskMetrics()
    
    public var completionHandler: ((Error?) -> Void)?
}


// MARK: - URLSessionTaskDelegate

extension Request: URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        isWaitingForConnectivity = true
        waitingForConnectivityHandler?()
    }
    
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        authenticationChallengeHandler(session, task, challenge, completionHandler)
    }
    
    public func urlSession(_ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics) {
        
        self.metrics = metrics
    }
    
    public func urlSession(_ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?) {
        
        completionHandler?(error)
        completionHandler = nil
        waitingForConnectivityHandler = nil
    }
}
