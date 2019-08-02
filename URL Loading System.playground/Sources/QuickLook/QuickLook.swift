import UIKit

public protocol PropertyPlaygroundQuickLookable: CustomPlaygroundQuickLookable {
    var propertyDescriptions: [String] { get }
}

extension PropertyPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return playgroundQuickLook(for: propertyDescriptions)
    }
}

public func playgroundQuickLook(for properties: [String]) -> PlaygroundQuickLook {
    let text = properties.joined(separator: "\n")
    
    let attributes: [NSAttributedStringKey: Any] = [
//        NSAttributedStringKey.font: UIFont.systemFont(ofSize: 40),
        NSAttributedStringKey.foregroundColor: UIColor.white,
    ]
    let string = NSAttributedString(string: text, attributes: attributes)
    return .attributedString(string)
}

extension Array where Element == String {
    mutating func append(_ label: String, with value: String?) {
        let string = value ?? "nil"
        append("\(label): \(string)")
    }
    
    mutating func append(_ label: String, with properties: [String]?) {
        if let values = properties {
            append("\(label):")
            append(contentsOf: values.map { "\t\($0)" })
        } else {
            append("\(label): nil")
        }
    }
    
    mutating func append(_ label: String, with value: Bool) {
        append(label, with: value.description)
    }
    
    mutating func append(_ label: String, with headers: [AnyHashable : Any]?) {
        append(label, with: headers?.map { "\($0): \($1)" })
    }
    
    mutating func append(_ label: String, with data: Data?) {
        append(label, with: data.flatMap { String(data: $0, encoding: .utf8) })
    }
}
