import UIKit

public struct QuickLook: CustomPlaygroundDisplayConvertible {
    let string: String

    public init(_ string: String) {
        self.string = string
    }

    public var playgroundDescription: Any {
        let textView = UITextView()
        textView.text = string
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.layer.cornerRadius = 4
        textView.sizeToFit()
        return textView
    }
}

extension String.StringInterpolation {

    public mutating func appendInterpolation<T>(
        unwrap value: T?
    ) where T: CustomStringConvertible {

        if let value = value {
            appendInterpolation(value)
        } else {
            appendLiteral("nil")
        }
    }
}
