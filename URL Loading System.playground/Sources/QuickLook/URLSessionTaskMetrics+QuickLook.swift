import Foundation

extension URLSessionTaskMetrics: PropertyPlaygroundQuickLookable {
    public var propertyDescriptions: [String] {
        var properties = [String]()
        properties.append("Task Interval", with: taskInterval.description)
        properties.append("Redirect Count", with: redirectCount.description)
        properties.append("Transaction Count", with: transactionMetrics.count.description)
        
        return properties
    }
}

extension URLSessionTaskTransactionMetrics: PropertyPlaygroundQuickLookable {
    public var propertyDescriptions: [String] {
        var properties = [String]()
        properties.append("Request", with: request.propertyDescriptions)
        properties.append("Response", with: response?.propertyDescriptions)
        properties.append("- Fetch Start Date", with: fetchStartDate?.description)
        properties.append("- Domain Lookup Start Date", with: domainLookupStartDate?.description)
        properties.append("- Domain Lookup End Date", with: domainLookupEndDate?.description)
        properties.append("- Connect Start Date", with: connectStartDate?.description)
        properties.append("  - Secure Connection Start Date", with: secureConnectionStartDate?.description)
        properties.append("  - Secure Connection End Date", with: secureConnectionEndDate?.description)
        properties.append("- Сonnect End Date", with: connectEndDate?.description)
        properties.append("- Request Start Date", with: requestStartDate?.description)
        properties.append("- Request End Date", with: requestEndDate?.description)
        properties.append("- Response Start Date", with: responseStartDate?.description)
        properties.append("- Response End Date", with: responseEndDate?.description)
        properties.append("Network Protocol Name", with: networkProtocolName)
        properties.append("Proxy Connection", with: isProxyConnection)
        properties.append("Reused Connection", with: isReusedConnection)
        properties.append("Resource Fetch Type", with: resourceFetchType.description)
        
        return properties
    }
}

extension URLSessionTaskMetrics.ResourceFetchType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .networkLoad:
            return "Network Load"
        case .serverPush:
            return "Server Push"
        case .localCache:
            return "Local Cache"
        }
    }
}
