/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # URL
 
 */
import Foundation


/*:
 # URLComponents
 */

var remoteUrl: String?
remoteUrl = "http://172.28.12.36/media/alfa_dev/content/2017-11-07/prescoring_2017_2_2_7vm0ylm_R7TeLa1.zip"

let fileUrl = URL(string: "http://172.28.12.36/media/alfa_dev/content/2017-11-07/prescoring_2017_2_2_7vm0ylm_R7TeLa1.zip")!

fileUrl.absoluteString
fileUrl.absoluteString == remoteUrl


//var url = URL(string: "activity")!
//let id = "1 /2-3\\"
//
//url.appendPathComponent(id)
//
//url.absoluteString.removingPercentEncoding
//id.removingPercentEncoding
//id.addingPercentEncoding(withAllowedCharacters: 0)

//var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
//urlComponents.url
//urlComponents.percentEncodedPath = id

/*:
 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */
