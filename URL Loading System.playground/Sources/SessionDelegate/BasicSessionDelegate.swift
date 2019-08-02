import Foundation

public class BasicSessionDelegate: NSObject, SessionDelagate {
    
    private var delegates: [Int: URLSessionTaskDelegate] = [:]
    
    public var operationQueue = OperationQueue.main
    
    public func setDelagate(_ delegate: URLSessionTaskDelegate, for task: URLSessionTask) {
        delegates[task.taskIdentifier] = delegate
    }
    
    internal func delagate(for task: URLSessionTask) -> URLSessionTaskDelegate? {
        return delegates[task.taskIdentifier]
    }
    
    internal func removeDelagate(for task: URLSessionTask) -> URLSessionTaskDelegate? {
        return delegates.removeValue(forKey: task.taskIdentifier)
    }
}


// MARK: - URLSessionTaskDelegate

extension BasicSessionDelegate: URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void)
    {
        if let delegate = self.delagate(for: task),
            delegate.responds(to: #selector(BasicSessionDelegate.urlSession(_:task:willPerformHTTPRedirection:newRequest:completionHandler:)))
        {
            delegate.urlSession?(session, task: task, willPerformHTTPRedirection: response, newRequest: request, completionHandler: completionHandler)
        } else {
            completionHandler(request)
        }
    }
    
    public func urlSession(_ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        if let delegate = self.delagate(for: task),
            delegate.responds(to: #selector(BasicSessionDelegate.urlSession(_:task:didReceive:completionHandler:)))
        {
            delegate.urlSession?(session, task: task, didReceive: challenge, completionHandler: completionHandler)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    public func urlSession(_ session: URLSession,
        task: URLSessionTask,
        needNewBodyStream completionHandler: @escaping (InputStream?) -> Void)
    {
        if let delegate = self.delagate(for: task),
            delegate.responds(to: #selector(BasicSessionDelegate.urlSession(_:task:needNewBodyStream:)))
        {
            delegate.urlSession?(session, task: task, needNewBodyStream: completionHandler)
        } else {
            completionHandler(nil)
        }
    }
    
    public func urlSession(_ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64)
    {
        guard let delegate = self.delagate(for: task) else { return }
        
        delegate.urlSession?(session,
            task: task,
            didSendBodyData: bytesSent,
            totalBytesSent: totalBytesSent,
            totalBytesExpectedToSend: totalBytesExpectedToSend)
    }
    
    public func urlSession(_ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics)
    {
        guard let delegate = self.delagate(for: task) else { return }
        
        delegate.urlSession?(session, task: task, didFinishCollecting: metrics)
    }
    
    public func urlSession(_ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?)
    {
        guard let delegate = self.removeDelagate(for: task) else { return }
        
        delegate.urlSession?(session, task: task, didCompleteWithError: error)
    }
}


// MARK: - URLSessionDataDelegate

extension BasicSessionDelegate: URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    {
        if let delegate = self.delagate(for: dataTask) as? URLSessionDataDelegate ,
            delegate.responds(to: #selector(BasicSessionDelegate.urlSession(_:dataTask:didReceive:completionHandler:)))
        {
            delegate.urlSession?(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler)
        } else {
            completionHandler(.allow)
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        guard let delegate = self.delagate(for: dataTask) as? URLSessionDataDelegate else { return }
        delegate.urlSession?(session, dataTask: dataTask, didBecome: downloadTask)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        guard let delegate = self.delagate(for: dataTask) as? URLSessionDataDelegate else { return }
        delegate.urlSession?(session, dataTask: dataTask, didBecome: streamTask)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let delegate = self.delagate(for: dataTask) as? URLSessionDataDelegate else { return }
        delegate.urlSession?(session, dataTask: dataTask, didReceive: data)
    }
    
    public func urlSession(_ session: URLSession,
        dataTask: URLSessionDataTask,
        willCacheResponse proposedResponse: CachedURLResponse,
        completionHandler: @escaping (CachedURLResponse?) -> Void)
    {
        if let delegate = self.delagate(for: dataTask) as? URLSessionDataDelegate ,
            delegate.responds(to: #selector(BasicSessionDelegate.urlSession(_:dataTask:willCacheResponse:completionHandler:)))
        {
            delegate.urlSession?(session, dataTask: dataTask, willCacheResponse: proposedResponse, completionHandler: completionHandler)
        } else {
            completionHandler(proposedResponse)
        }
    }
}
