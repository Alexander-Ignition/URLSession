import Foundation

extension HTTPCookieStorage: PropertyPlaygroundQuickLookable {
    public var propertyDescriptions: [String] {
        var properties = [String]()
        properties.append("cookies", with: cookies?.description)
        properties.append("AcceptPolicy", with: cookieAcceptPolicy.description)
        
        return properties
    }
}

extension HTTPCookie: PropertyPlaygroundQuickLookable {
    public var propertyDescriptions: [String] {
        var properties = [String]()
        self.properties?.forEach { properties.append($0.rawValue, with: "\($1)") }
        
        return properties
    }
}


// MARK: - CustomStringConvertible

extension HTTPCookie.AcceptPolicy: CustomStringConvertible {
    public var description: String {
        switch self {
        case .always:
            return "Accept all cookies"
        case .never:
            return "Reject all cookies"
        case .onlyFromMainDocumentDomain:
            return "Accept cookies only from the main document domain"
        }
    }
}
