/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # Logging
 
 Очень часто нам нужно выводить логи, чтобы понять какие ответы пришли на запросы. 
 Самый простой способ обложить все `print`, но каждый раз модицифицировать код не самый лучший вариант. 
 Гораздо лучше бы было иметь одну точку перехевата запросов и если нужно включать логирование, а если нужно выключать.
 
 По стойте! У нас же как раз есть для этого `URLProtocol`!
 
 Сделаем своего наследника `URLProtocol`, который будет вызывать методы объекта, который реализует протокол `DataTaskLogger`.
 Он добольно прост и имеет вад метода: о начале загрузке и о её завершении.
 */
/*:
 ## URLProtocol
 
 Наш `DataTaskLogProtocol` имеет статичное поле для установки логгера.
 Что поделать если за его создание будет отвечать `URLSession`?
 
 Так же есть проперти `dataTask`, который сам пойдет в сеть и вернет ответ, и `data` тело ответа сервера.
 */
import Foundation

final class LogProtocol: URLProtocol {
    
    static let didStartLoading = Notification.Name("com.example.LogProtocol.didStartLoading")
    static let didStopLoading = Notification.Name("com.example.LogProtocol.didStopLoading")
    
    private static let sessionManager = SessionManager(
        configuration: .ephemeral,
        delegate: AsyncSessionDelegate())
    
    
    let dataTask: URLSessionDataTask
    
    fileprivate(set) var data = Data()
    
    
    // MARK: - URLProtocol
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        return task is URLSessionDataTask
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        dataTask = LogProtocol.sessionManager.session.dataTask(with: request)
        super.init(request: request, cachedResponse: cachedResponse, client: client)
        LogProtocol.sessionManager.sessionDelegate.setDelagate(self, for: dataTask)
    }
    
    override func startLoading() {
        dataTask.resume()
        NotificationCenter.default.post(name: LogProtocol.didStartLoading, object: self)
    }
    
    override func stopLoading() {
        dataTask.cancel()
        NotificationCenter.default.post(name: LogProtocol.didStopLoading, object: self)
    }
}
/*:
 `URLProtocol` - абстрактный класс и нужно переопределить его методы.
 
 1. `canInit` - говорит, что мы будем обрабатывать только `URLSessionDataTask`.
 2. `canonicalRequest` показывет, что мы никак не модифицируем оригинальный запрос.
 3. В конструкторе мы создаем `dataTask` и назначаем `DataTaskLogProtocol` его делгатом.
 4. `startLoading` - запускаем запрос на сервер и вызываем метод логера о начале запроса.
 5. `stopLoading` - завершаем запрос и оповещаем логгера.
 
 - Note:
 Для создания `dataTask` и установки делегата используется статичное поле `sessionManager`.
 Его исходники лежать в папке Source к этой странице playground'а.
 О его принципе работы было рассказано в соответсвующей [главе](SessionManager).
 
 - Important:
 Если же использовать синглтон `URLSession.shared` для создания `dataTask`, 
 то не получится установить делегата задачи и правильно пробросить все его вызовы на клиента протокола.
 Также придется решать проблему зацикливания протокола, что не очень сложно, но проще сделать так, чтобы её не было.
 
 Осталось реализовать методы делегата задачи.
 
 
 ## URLSessionDataDelegate
 
 В первую очередь мы хотели логировать ответы сервера а точнее тело этих ответов.
 Для этого мы нанем с метода `urlSession(_:dataTask:didReceive:)` который получает куски бинарных данных.
 Их мы будем добавлять к проперти `data` и прокидыаать дальше на верх, то есть вызывать аналогичный метод у `URLProtocolClient`.
 
 Если забыть передавать `URLProtocolClient` ответ `URLResponse`, то он не вернется вызывающей строне выше, 
 по этому нужно реализовать метод `urlSession(_:dataTask:didReceive:completionHandler:)` и передать ответ клиенту в `urlProtocol(_:didReceive)`.
 */
extension LogProtocol: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.data.append(data)
        client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }
}
/*:
 ## URLSessionTaskDelegate
 
 Не забывайте, что `URLSessionDataDelegate` наследуется от `URLSessionTaskDelegate`.
 В нем находится метод завершения задачи `urlSession(_:task:didCompleteWithError:)`.
 
 Без вызова у клиента `urlProtocolDidFinishLoading(_:)` логируемый запрос не завершится.
 Но перед этим мы должны проверить, что задача завершилась без ошибки.
 Если ошибка имеется, то её нужно пробросить клиенту в `urlProtocol(_:didFailWithError:)`
 */
extension LogProtocol: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    func urlSession(_ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        let sender = AuthenticationChallengeSender(completionHandler: completionHandler)
        let newChallenge = URLAuthenticationChallenge(authenticationChallenge: challenge, sender: sender)
        client?.urlProtocol(self, didReceive: newChallenge)
    }
}
/*:
 Почти все запросы на апи в современном мире ходят по HTTPS для обеспечения безопасности.
 Для обработки этого у `URLSessionTaskDelegate` есть метод `urlSession(_:task:didReceive:completionHandler:)`,
 а у `URLProtocolClient` есть `urlProtocol(_:didReceive)`.
 
 Без вызова этого метода запрос не сможет быть нормально обработан и как следствие залогирован.
 Все ваше общение с сервером будет прерванно, из-за такого логера.
 
 Но вод ведь беда эти два метода плохо совместимы. Метод делегата задачи передает замыкание, которое нужно вызвать, 
 а метод клиента просто принимает `challenge` и ничего назад не возвращает.
 
 Для того, чтобы это решить, воспользуемся конструктором `URLAuthenticationChallenge`, который принимает другой такой же `challenge`, копирует все значения из него и принимает еще и `sender`, который реализует протокол `URLAuthenticationChallengeSender`.
 
 После этого новый `challenge` мы просто отправляем вверх клиенту.
 
 
 ## URLAuthenticationChallengeSender
 
 `AuthenticationChallengeSender` - представляет из себя обертку над замыканием типа `(URLSession.AuthChallengeDisposition, URLCredential?) -> Void` и реализует протокол `URLAuthenticationChallengeSender`.
 */
final class AuthenticationChallengeSender: NSObject {
    
    typealias CompletionHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    
    fileprivate let completionHandler: CompletionHandler
    
    init(completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
        super.init()
    }
}
/*:
 Методы протокола `URLAuthenticationChallengeSender` почти полностью соотвествуют `URLSession.AuthChallengeDisposition`, 
 что позвалает нам сделать адаптер над замыканием.
 */
extension AuthenticationChallengeSender: URLAuthenticationChallengeSender {
    
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
 ## Usage
 
 Настало время проверить нашего менеджера.
 
 Для примера создадим простой логгер, который будет просто печатать сообщения о начале и конце запроса.
 */
NotificationCenter.default.addObserver(
    forName: LogProtocol.didStopLoading,
    object: nil,
    queue: .main) { notification in
        notification
        print("[LOGGER START]: ", notification)
    }

NotificationCenter.default.addObserver(
    forName: LogProtocol.didStopLoading,
    object: nil,
    queue: .main) { notification in
        notification
        print("[LOGGER END]: ", notification)
    }
/*:
 Добавим его в url протокол.
 */
/*:
 Зарегистрируем протокол логгера для использования с синглтоном `URLession`.
 */
URLProtocol.registerClass(LogProtocol.self)
/*:
 Сделаем и отправим запрос на сервер.
 */
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

let request = URLRequest(url: URL(string: "https://google.com")!)

URLSession.shared.dataTask(with: request) {
    (data: Data?, response: URLResponse?, error: Error?) in
    
    if let error = error {
        print("[ERROR]: \(error)")
    }
    if let response = response {
        print("[RESPONSE]: \(response)")
    }
    if let data = data {
        print("[DATA]: \(String(data: data, encoding: .windowsCP1251)!)")
    }
    PlaygroundPage.current.finishExecution()
} .resume()
/*:
 Открыв лог, вы сможете увидеть распечатку запроса.

 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */
