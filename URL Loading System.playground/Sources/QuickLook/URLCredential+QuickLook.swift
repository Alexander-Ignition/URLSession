import Foundation

extension URLCredential: PropertyPlaygroundQuickLookable {
    public var propertyDescriptions: [String] {
        var properties = [String]()
        properties.append("persistence", with: persistence.description)
        
        if let user = self.user, let password = password {
            properties.append("type", with: "NSInternetPassword")
            properties.append("user", with: user)
            properties.append("password", with: password)
        } else if self.identity != nil {
            properties.append("type", with: "NSClientCertificate")
//            properties.append("identity", with: Sttring(identity))
            properties.append("certificates", with: certificates.description)
        } else {
            properties.append("type", with: "NSServerTrust")
        }
        
        return properties
    }
}

extension URLProtectionSpace: PropertyPlaygroundQuickLookable {
    public var propertyDescriptions: [String] {
        var properties = [String]()
        properties.append("realm", with: realm)
        properties.append("Receives Credential Securely", with: receivesCredentialSecurely)
        properties.append("host", with: host)
        properties.append("port", with: port.description)
        properties.append("protocol", with: self.protocol)
        properties.append("Authentication Method", with: realm)
        properties.append("Proxy", with: isProxy())
        properties.append("Distinguished Names", with: distinguishedNames?.description)
//            properties.append("identity", with: Sttring(identity))
        return properties
    }
}

extension URLCredentialStorage: PropertyPlaygroundQuickLookable {
    public var propertyDescriptions: [String] {
        var properties = [String]()
        properties.append("allCredentials", with: allCredentials)
        
        return properties
    }
}

extension URLCredential.Persistence: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none:
            return "none"
        case .forSession:
            return "forSession"
        case .permanent:
            return "permanent"
        case .synchronizable:
            return "synchronizable"
        }
    }
}
