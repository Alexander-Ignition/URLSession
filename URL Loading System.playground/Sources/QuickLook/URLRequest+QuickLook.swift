import Foundation

extension URLRequest: PropertyPlaygroundQuickLookable {
    public var propertyDescriptions: [String] {
        var properties = [String]()
        properties.append("URL", with: url?.absoluteString)
        properties.append("Cache Policy", with: cachePolicy.description)
//        properties.append("Timeout Interval", with: timeoutInterval.description)
//        properties.append("Main Document URL", with: mainDocumentURL?.absoluteString)
//        properties.append("Network Service Type", with: networkServiceType.description)
//        properties.append("Cellular Access", with: allowsCellularAccess.description)
        properties.append("HTTP Method", with: httpMethod)
        properties.append("HTTP Header Fields", with: allHTTPHeaderFields)
        properties.append("HTTP Body", with: httpBody)
//        properties.append("HTTP Body Stream", with: httpBodyStream?.description)
//        properties.append("HTTP should handle Cookies", with: httpShouldHandleCookies)
//        properties.append("HTTP should use Pipelining", with: httpShouldUsePipelining)
        
        return properties
    }
}

// MARK: - CustomStringConvertible

extension URLRequest.CachePolicy: CustomStringConvertible {
    public var description: String {
        switch self {
        case .useProtocolCachePolicy:
            return "Use protocol cache policy"
        case .reloadIgnoringLocalCacheData:
            return "Reload ignoring Local cache data"
        case .reloadIgnoringLocalAndRemoteCacheData:
            return "Reload ignoring Local and Remote cache data (Unimplemented)"
        case .returnCacheDataElseLoad:
            return "Return cache data else Load"
        case .returnCacheDataDontLoad:
            return "Return cache data Dont Load"
        case .reloadRevalidatingCacheData:
            return "Reload Revalidating cache data (Unimplemented)"
        }
    }
}

extension URLRequest.NetworkServiceType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .default:
            return "Standard internet traffic"
        case .voip:
            return "Voice over IP control traffic"
        case .video:
            return "Video traffic"
        case .background:
            return "Background traffic"
        case .voice:
            return "Voice data"
        case .networkServiceTypeCallSignaling:
            return "Call Signaling"
        }
    }
}
