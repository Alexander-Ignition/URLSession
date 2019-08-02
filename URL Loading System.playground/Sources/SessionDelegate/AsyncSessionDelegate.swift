import Foundation

public final class AsyncSessionDelegate: BasicSessionDelegate {
    
    public override init() {
        super.init()
        operationQueue = OperationQueue()
        operationQueue.qualityOfService = .utility
        operationQueue.maxConcurrentOperationCount = 1
    }
    
    public override func setDelagate(_ delegate: URLSessionTaskDelegate, for task: URLSessionTask) {
        operationQueue.addOperation {
            super.setDelagate(delegate, for: task)
        }
    }
}
