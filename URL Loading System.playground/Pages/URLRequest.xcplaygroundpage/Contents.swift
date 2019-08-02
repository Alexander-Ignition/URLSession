/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # URLRequest
 
 */
import Foundation

/*:
 ## init
 */
let url = URL(string: "https://api.example.com/book")!

var request = URLRequest(url: url)

let request2 = URLRequest(
    url: url,
    cachePolicy: .returnCacheDataDontLoad,
    timeoutInterval: 10)
/*:
 NSURLRequest (NSHTTPURLRequest)
 NSMutableURLRequest (NSMutableHTTPURLRequest)
 
 ## General
 */
request.url
request.cachePolicy
request.timeoutInterval

request.mainDocumentURL
request.networkServiceType
request.allowsCellularAccess

/*:
 ## HTTPURLRequest
 
 ### HTTP Method
 */
request.httpMethod = "POST"
/*:
 ### HTTP Header Fields
 */
request.allHTTPHeaderFields
request.setValue("1", forHTTPHeaderField: "X-Test")
request.addValue("2", forHTTPHeaderField: "X-Test")
/*:
 ### HTTP Body
 */
request.httpBody
request.httpBodyStream

/*:
 ### HTTP Cookie && Pipelining
 */
request.httpShouldHandleCookies
request.httpShouldUsePipelining

/*:
 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */
