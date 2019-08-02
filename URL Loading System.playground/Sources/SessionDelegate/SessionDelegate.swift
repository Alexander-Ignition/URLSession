import Foundation

public protocol SessionDelagate: URLSessionDelegate {
    
    var operationQueue: OperationQueue { get }
    
    func setDelagate(_ delegate: URLSessionTaskDelegate, for task: URLSessionTask)
}
