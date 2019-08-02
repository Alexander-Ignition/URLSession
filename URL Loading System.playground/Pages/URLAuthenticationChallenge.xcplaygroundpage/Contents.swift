/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # URLAuthenticationChallenge
 
 */
import Foundation
import WebKit
/*:
 ## Did receive... challenge!
 
 URLSessionDelegate
 URLSessionTaskDelegate
 WKNavigationDelegate
 */
final class SessionDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let credential = URLCredential(user: "admin", password: "1234", persistence: .forSession)
        completionHandler(.useCredential, credential)
    }
}

final class TaskDelegate: NSObject, URLSessionTaskDelegate {
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}

final class WebNavigationDelegate: NSObject, WKNavigationDelegate {
    
    func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(.performDefaultHandling, nil)
    }
}

func didReceive(
    _ challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    
    completionHandler(.rejectProtectionSpace, nil)
}

/*:
 ## URLSession.AuthChallengeDisposition
 
 - `.useCredential` Use the specified credential, which may be nil
 - `.performDefaultHandling` Default handling for the challenge - as if this delegate were not implemented; the credential parameter is ignored.
 - `.cancelAuthenticationChallenge` The entire request will be canceled; the credential parameter is ignored.
 - `.rejectProtectionSpace` This challenge is rejected and the next authentication protection space should be tried; the credential parameter is ignored.
 */

/*:
 ## URLCredential
 
 ### URLCredential(NSInternetPassword)
 ### URLCredential(NSClientCertificate)
 ### URLCredential(NSServerTrust)
 */

/*:
 ## URLAuthenticationChallengeSender
 */
final class AuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender {
    
    private let completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    
    init(completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        self.completionHandler = completionHandler
        super.init()
    }
    
    
    // MARK: - URLAuthenticationChallengeSender
    
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
        completionHandler(.useCredential, credential)
    }
    
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
        completionHandler(.performDefaultHandling, nil)
    }
    
    func cancel(_ challenge: URLAuthenticationChallenge) {
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
    
    func performDefaultHandling(for challenge: URLAuthenticationChallenge) {
        completionHandler(.performDefaultHandling, nil)
    }
    
    func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {
        completionHandler(.rejectProtectionSpace, nil)
    }
}
/*:
 ## URLAuthenticationChallenge
 */

/*:
 ## URLProtectionSpace
 */

/*:
 ## URLCredentialStorage
 */

/*:
 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */
