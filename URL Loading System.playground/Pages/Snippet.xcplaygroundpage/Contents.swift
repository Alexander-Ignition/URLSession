/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # <#Заголовок#>
 
 <# Text #>
 
 [Markup Formatting Reference](https://developer.apple.com/library/content/documentation/Xcode/Reference/xcode_markup_formatting_ref/index.html#//apple_ref/doc/uid/TP40016497-CH2-SW1)
 
 * Example:
 <#Пример#>
 
 - Important:
 <#Важно#>
 
 * Note:
 <#Заметка#>
 
 - Experiment:
 <#Эксперимент#>
 
 * Callout(Challenge):
 <#Испытание#>
 
 ![Simple request](simple_request.png)
 
 ```
 func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
 
    if let delegate = self[task],
        delegate.responds(to: #selector(BasicSessionDelegate.urlSession(_:task:didReceive:completionHandler:))) {
 
        delegate.urlSession!(session, task: task, didReceive: challenge, completionHandler: completionHandler)
    } else {
        completionHandler(.performDefaultHandling, nil)
    }
 }
 ```
 
 */

/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # <#Заголовок#>
 
 */

/*:
 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
