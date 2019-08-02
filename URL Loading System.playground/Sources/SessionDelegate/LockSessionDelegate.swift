import Foundation

public final class LockSessionDelegate: BasicSessionDelegate {
    
    private let lock = NSLock()
    
    public override init() {
        super.init()
        operationQueue = OperationQueue()
        operationQueue.qualityOfService = .utility
    }
    
    public override func setDelagate(_ delegate: URLSessionTaskDelegate, for task: URLSessionTask) {
        lock.lock(); defer { lock.unlock() }
        
        super.setDelagate(delegate, for: task)
    }
    
    override func delagate(for task: URLSessionTask) -> URLSessionTaskDelegate? {
        lock.lock(); defer { lock.unlock() }
        
        return super.delagate(for: task)
    }
    
    override func removeDelagate(for task: URLSessionTask) -> URLSessionTaskDelegate? {
        lock.lock(); defer { lock.unlock() }
        
        return super.removeDelagate(for: task)
    }
    
}
