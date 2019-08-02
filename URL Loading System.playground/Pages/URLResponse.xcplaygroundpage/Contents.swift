/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****

 # Response
 
 Все запросы в сеть мы делаем ради того, чтобы получить ответ с полезной для нас информацией.
 Самый минимальный набор ответа состоит из опциональных типов `Data`, `URLResponse` и `Error` - тело ответа, метаданные ответа, и сетевая ошибка.
 */
import Foundation

let url = URL(string: "http://example.com/api/users")!

URLSession.shared.dataTask(with: url) {
    (data: Data?, response: URLResponse?, error: Error?) in
    
    // check error
    // handle response
    // serialize data
}
/*:
 Из них могут получаться разные комбинации ответа.
 - В успешном запросе мы получим в ответ `(Data, URLResponse, nil)`.
 - Например если произойдет сетевая ошибка, то вернется такой набор `(nil, nil, URLError)`
 - Ответ сервера тоже может вернутся c ошибкой `(Data, URLResponse, nil)`, и этот набор мы сможем отличить от успешного только по метадате ответа.
 
 - Important:
 Не забывайте как можно полно обрабатывать все возможные ответы сервера
 
 Наверно вам уже бросилось в глаза то, что тело ответа `Data?` не явялется частью `URLResponse`, как у `URLRequest`, у которого тело можно просто записать в свойтво `httpBody`.
 */
var request = URLRequest(url: url)
request.httpBody = "Hello!".data(using: .utf8)
/*:
 * Note:
 Связь между телом ответа и его матаданными в `Foundation` реализована только в `CachedURLResponse`, но это уже совсем другая история про кеширование.
 
 Это не единственное отличие между ними.
 
 Во времена Objective-C `URLRequest` был классом `NSURLRequest`, который содержал свойства связаные с `URL`.
 Поля же связанные с HTTP лежали в именнованной категории `NSURLRequest (NSHTTPURLRequest)`.
 Так это перешло и в Swift где класс `NSURLRequest` стал структурой `URLRequest`, у которой есть все URL и HTTP свойства.
 */
request.httpMethod = "POST"
request.addValue("1", forHTTPHeaderField: "x-test")
/*:
 `URLResponse` остался классом и сохранил своего наследника `HTTPURLResponse`, в котором находятся все HTTP свойства.
 
 О них и мы и поговорим.
 
 
 ## URLResponse
 
 `URLResponse` - самый базовый класс представляющий метаданные ответа.
 */
let urlResponse = URLResponse(
    url: url,
    mimeType: "text/html",
    expectedContentLength: 5321,
    textEncodingName: "utf-8")
/*:
 Он конечно же содержит `URL`, ответа на который описывает.
 */
urlResponse.url
urlResponse.url == url
/*:
 MIME-тип, означающий что пришло в теле.
 Например: application/json, text/html, text/plain,
 */
urlResponse.mimeType
/*:
 Ожидаемая длина тела ответа.
 */
urlResponse.expectedContentLength
/*:
 Имя кодировки тела ответа.
 */
urlResponse.textEncodingName
/*:
 Предполагаемое имя файла ответа.
 Оно составляется из последней части пути `URL` + расширение на основе `mimeType`
 */
urlResponse.suggestedFilename

/*:
 ## HTTPURLResponse
 
 Чаще всего мы работаем по HTTP и ожидаем соотвествующего ответа со статус кодом и заголовками.
 Все это добавляется в наследнике `URLResponse` - `HTTPURLResponse`, что и видно в параметрах нового инициализатора.
 
 `httpVersion` - это версия HTTP ответа, чаще всего она бывает "HTTP/1.1", но можно и просто передать `nil`.
 */
let httpResponse = HTTPURLResponse(
    url: url,
    statusCode: 200,
    httpVersion: "HTTP/2",
    headerFields: [
        "Content-Length": "5321",
        "Content-Type": "text/html; charset=windows-1251",
    ])!
/*:
 Больше всего полезной информации для нас собрано в `headerFields`. 
 Там могут находится cookie, заголовки кеширования и дргуая информация которую нам отправил сервер.
 */
httpResponse.allHeaderFields
/*:
 Значения свойства, которые мы передавали в инициализатор `URLResponse`, нам также доступны, но теперь их значения берутся из `headerFields`, из ключей: `Content-Length` и `Content-Type`.
 */
httpResponse.mimeType
httpResponse.expectedContentLength
httpResponse.textEncodingName
httpResponse.suggestedFilename
/*:
 ### Status Code
 
 Обычно успешность запроса мы определаем по статус коду ответа.
 Если он 200, то мы пробуем серилизовать ответ, если он 400 - 500, то мы обрабатывааем ответ, как ошибку.
 */
httpResponse.statusCode
/*:
 Для текстового представления статус кода у `HTTPURLResponse` есть метод клаасс.
 */
HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
/*:
 ### HTTPError
 
 Хорошим тоном будет создать специальную ошибку для статус кодов которые вы не ожидали получить в ответе.
 В таком случае не забудьте положить в ошибку сам `HTTPURLResponse` так и его тело.
 В теле может находится дополнительная информация подробно описывающая что пошло не так.
 Старайтесь чтобы выши ошибки содержали максимально полную информацию, о том что пошло не так.
 */
struct HTTPError: Error {
    let request: URLRequest
    let response: HTTPURLResponse
    let data: Data?
}
/*:
 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */
