/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 #  URLProtocol
 
 C самого начала документации [NSURLSession](https://developer.apple.com/documentation/foundation/urlsession) упоминается, что сессия поддреживает загрузку контента через протоколы:
 
 - File Transfer Protocol (ftp://)
 - Hypertext Transfer Protocol (http://)
 - Hypertext Transfer Protocol with encryption (https://)
 - Local file URLs (file:///)
 - Data URLs (data://)
 - SPDY,
 - HTTP2
 
 Класс который отвечает за реализацию этих протоколов называется `URLProtocol`. 
 Это абстрактный класс и унаследовавшись от него мы можем реализовать свой протокол.
 Это самая низкая часть сетевого взаимодействия во фреймворке `Foundation`.
 
 Мы можем узнать протоколы по умолчанию заглянув в `URLSessionConfiguration.protocolClasses`
 */
import Foundation

let configuration = URLSessionConfiguration.default

configuration.protocolClasses // [Swift.AnyClass]?
let protocolClasses = configuration.protocolClasses as! [URLProtocol.Type]
/*:
 Все они соотвествуют ранее перечисленным схемам URL.
 - `_NSURLHTTPProtocol`
 - `_NSURLDataProtocol`
 - `_NSURLFTPProtocol`
 - `_NSURLFileProtocol`
 - `NSAboutURLProtocol`
 
 
 ## Registry
 
 В `URLSessionConfiguration.protocolClasses` мы можем добавить и свои протоколы, если мы создаем сессию сами.
 Если же мы используем синглтон сессии `URLSession.shared`, то для добавления и удаления протоколов 
 нужно воспользоваться методами у `URLProtocol`.
 
 ```
 open class URLProtocol : NSObject {
    // ...
 
    open class func registerClass(_ protocolClass: Swift.AnyClass) -> Bool
    open class func unregisterClass(_ protocolClass: Swift.AnyClass)
 }
 ```
 
 `URLSession` появилась только в iOS 7, до нее был только `URLConnection`, который уже признан устаревшим и не используется.
 В `URLProtocol` осталось много методов для совместимости со старым АПИ, но и для нового АПИ в нем были добавлены методы для работы с `URLSessionTask`.
 
 C тех времен у `URLProtocol` остались методы для установки пропертей в запросы.
 С их помощью можно было пометить, что запрос уже принят и не обработывать его в следующем цикле.
 Это возникало из-за того что протокол можно было установить глобавльно и он начинал обрабатывать абсолютно все запросы.
 ```
 open class URLProtocol : NSObject {
    // ...
 
    open class func property(forKey key: String, in request: URLRequest) -> Any?
    open class func setProperty(_ value: Any, forKey key: String, in request: NSMutableURLRequest)
    open class func removeProperty(forKey key: String, in request: NSMutableURLRequest)
 }
 ```
 
 
 ## Life Cycle
 
 1. `canInit(with:)` - Имеет варианты с `URLRequest` и  `URLSessionTask`
 2. `canonicalRequest(for:)`
 3. `requestIsCacheEquivalent(:to:)` - Необязательный метод для переопределения
 4. `init(request:cachedResponse:client:)` - Имеет арианты с `URLRequest` и  `URLSessionTask`
 5. `startLoading()`
 6. `stopLoading()`
 
 
 ### `canInit(with:)`
 
 Когда начинается выполнение `URLSessionTask`, сессия создавшая его, 
 ищет протокол, который смог бы обработать запрос.
 
 Для этого она ищет среди протоколов `configuration.protocolClasses`,
 тот который бы мог быть инициализирован запросом либо задачей.
*/
let httpsRequest = URLRequest(url: URL(string: "https://api.site.com")!)
let httpProtocolClass = protocolClasses.first(where: {
    $0.canInit(with: httpsRequest)
})
httpProtocolClass

let fileProtocolClass = protocolClasses.first(where: {
    $0.canInit(with: URLRequest(url: URL(string: "file://dfds")!))
})
fileProtocolClass

let aboutProtocolClass = protocolClasses.first(where: {
    $0.canInit(with: URLRequest(url: URL(string: "about://dfds")!))
})
aboutProtocolClass
/*:
 ### `canonicalRequest(for:)`
 
 После того как класс протокола найден вызывается метод `canonicalRequest(for:)`.
 Внем протокол может модифицировать запрос перед своей инициализацией.
 
 `_NSURLHTTPProtocol` добавляет дополнительные поля в хедер запроса, если они были `nil` в оригинальном запросе.
 */
let canonicalHttpRequest = httpProtocolClass!.canonicalRequest(for: httpsRequest)
canonicalHttpRequest.allHTTPHeaderFields
httpsRequest.allHTTPHeaderFields
/*:
 ### `requestIsCacheEquivalent(:to:)`
 
 Не обязательный протокол для переопределения.
 В нем просто сравниваются два запроса для подбора закешированного результата.
 
 
 ## `init(request:cachedResponse:client:)`
 
 Инициализироваться протокол может либо запросом либо задачей.
 По мимо них он принимает закешированный результат и клиента.

 Клиент - это объект реализующий протокол `URLProtocolClient`.
 Ему отдаются все результаты асинхронного выполнения `URLProtocol`.
 
 
 ## `startLoading()`
 
 Начало выполнения запроса.
 
 
 ## `stopLoading()`
 
 Завершение выполнения запроса.
 
 
 #  URLProtocolClient
 
 Мой рассказ не был бы полным без этого протокола. Ведь именно в него `URLProtocol` отдает результаты своей работы.
 
 ### `urlProtocol(_:wasRedirectedTo:redirectResponse:)`
 
 Для оповещения о том, что произошел редирект запроса.
 
 ### `urlProtocol(_:cachedResponseIsValid:)`
 
 Закешированный ответ пригоден для использования.
 
 ### `urlProtocol(_:didReceive:cacheStoragePolicy:)`
 
 Пришел ответ от сервера.
 
 ### `urlProtocol(_:didLoad:)`
 
 Была получена часть данных от тела ответа сервера.
 
 ### `urlProtocolDidFinishLoading(_:)`
 
 Протокол завершил выполнение.
 
 ### `urlProtocol(_:didFailWithError:)`
 
 Произошла ошибка в процессе выполнения.
 
 - Note:
 Все эти методы похожи на методы делегата задачи сессии, но еще больше они совпадают с делегатом `URLConnection`.
 
 
 ## Conclusion
 
 Теперь вы имеет представление о `URLProtocol` и то что он позваляет быть прослойкой на нижнем уровне обработки запроса.
 
 Делать кастомную загрузку выдуманного соединения думаю было бы скучно и мало полезно, по этому вы сможете узнать больше о практике его применения в следующих главах [Mocking](Mocking) и [Logging](Logging).
 
 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */
