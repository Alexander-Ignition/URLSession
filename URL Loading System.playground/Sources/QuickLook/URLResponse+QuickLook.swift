import Foundation

extension URLResponse: PropertyPlaygroundQuickLookable {
    public var propertyDescriptions: [String] {
        var properties = [String]()
        properties.append("URL", with: url?.absoluteString)
        properties.append("Mime Type", with: mimeType)
        properties.append("Expected Content Length", with: expectedContentLength.description)
        properties.append("Text Encoding Name", with: textEncodingName)
        properties.append("Suggested Filename", with: suggestedFilename)
        
        if let httpRsponse = self as? HTTPURLResponse {
            properties.append(contentsOf: httpRsponse.httpProperties)
        }
        return properties
    }
}

extension HTTPURLResponse {
    var httpProperties: [String] {
        var properties = [String]()
        let status = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        properties.append("HTTP Status Code", with: "\(statusCode), \(status)")
        properties.append("HTTP Header Fields", with: allHeaderFields)
        return properties
    }
}
