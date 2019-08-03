import Foundation

extension URLResponse: CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        var string = """
        URL: \(unwrap: url)
        Mime Type: \(unwrap: mimeType)
        Expected Content Length: \(expectedContentLength)
        Text Encoding Name: \(unwrap: textEncodingName)
        Suggested Filename: \(unwrap: suggestedFilename)
        """
        if let http = self as? HTTPURLResponse {
            let text = """

            HTTP status: \(http.statusCode), \(HTTPURLResponse.localizedString(forStatusCode: http.statusCode))
            HTTP header fields: \(unwrap: http.allHeaderFields)
            """
            string.append(text)
        }
        return QuickLook(string)
    }
}
