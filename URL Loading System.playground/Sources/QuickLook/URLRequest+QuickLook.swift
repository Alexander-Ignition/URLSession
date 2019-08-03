import Foundation

extension URLRequest: CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        let string = """
        URL: \(unwrap: url)
        HTTP method: \(unwrap: httpMethod)
        HTTP header fields: \(unwrap: allHTTPHeaderFields)
        HTTP body: \(unwrap: httpBody)
        Timeout Interval: \(timeoutInterval)
        Network Service Type: \(networkServiceType)
        Cache Policy: \(cachePolicy)
        """
        return QuickLook(string)
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
        @unknown default:
            return "\(self)"
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
        case .responsiveData:
            return "Responsive Data"
        case .callSignaling:
            return "Call Signaling"
        @unknown default:
            return "\(self)"
        }
    }
}

