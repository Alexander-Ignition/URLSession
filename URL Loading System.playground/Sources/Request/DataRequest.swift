import Foundation

public final class DataRequest: Request {

    public private(set) var data = Data()
    
    public var dataTask: URLSessionDataTask { return task as! URLSessionDataTask }
    
    public init(dataTask: URLSessionDataTask) {
        super.init(task: dataTask)
    }
}


// MARK: - URLSessionDataDelegate

extension DataRequest: URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data)
    {
        self.data.append(data)
    }
}
