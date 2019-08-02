import Foundation

public final class BarrierSessionDelegate: BasicSessionDelegate {
    
    private let queue = DispatchQueue(
        label: "com.example.BarrierSessionDelegate.queue",
        attributes: .concurrent)
    
    public override init() {
        super.init()
        operationQueue = OperationQueue()
        operationQueue.qualityOfService = .utility
    }
    
    public override func setDelagate(_ delegate: URLSessionTaskDelegate, for task: URLSessionTask) {
        queue.async(flags: .barrier) {
            super.setDelagate(delegate, for: task)
        }
    }
    
    override func delagate(for task: URLSessionTask) -> URLSessionTaskDelegate? {
        return queue.sync {
            super.delagate(for: task)
        }
    }
    
    override func removeDelagate(for task: URLSessionTask) -> URLSessionTaskDelegate? {
        return queue.sync {
            super.removeDelagate(for: task)
        }
    }
    
}
