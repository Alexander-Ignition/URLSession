/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # HTTPCookie

 Протокол HTTP не имеет состояние. Каждый запрос не зависит от других.
 Это делает базовые вещи проще, но в то же время усложняет другие.
 
 Серверу было бы не возможно отследить, что мы положили в корзину сайта, или, что мы уже авторизовались и нам бы пришлось в каждом запросе посылать логин и пароль.
 Это большие усложнения, не говоря уже о безопасности. Логин и пароль могут быть укардены и лучше их совсем не запоминать и хранить.
 
 Для решения проблемы состояний были придуманы Cookie. Они позволяют вернуть клиенту определенную строку в заголовке ответа, после чего клиент должен будет посылать запросы вместе с этой строкой.
 
 Например отправля запрос
*/
import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

let url = URL(string: "https://google.com/")!
var request = URLRequest(url: url)
/*:
 В ответ на него сервер пришлет cookie, которые представляют из себя строку в определенном формате.
 */
let rawCookie = "NID=112=vGL-T-jxIxemP-X6CsT7gK9HY-7u1DX2Sa9eFRk_ngTJ5FwozbmIyh7UsOAUX0AdVhMIGH7WTnNZU7WJ4-exj909pn1cCRG9hqwGjtT3DqJmoflaS-YU3Ciaq-QkFWIp; expires=Mon, 19-Mar-2018 16:36:11 GMT; path=/; domain=.google.ru; HttpOnly"
/*:
 Cooke будут лежать в заголовке ответа сервера по ключу `Set-Cookie`.
 Так сервер сообщает клиенту, что ему нужно запомнить cookie.
 */
let httpResponse = HTTPURLResponse(
    url: URL(string: "https://www.google.ru/?gfe_rd=cr&dcr=0&ei=21a-Weu_LMzi8AeB8biIDQ")!,
    statusCode: 200,
    httpVersion: nil,
    headerFields: [
        "Content-Length": "5321",
        "Content-Type": "text/html; charset=windows-1251",
        "Set-Cookie": rawCookie
    ])!

httpResponse
/*:
 Нам не нужно вручную разбирать ответ и парсить строку.
 */
httpResponse.allHeaderFields["Set-Cookie"]
/*:
 Мы можем воспользоваться классом `HTTPCookie`, который все сделает за нас.
 */
let cookies: [HTTPCookie] = HTTPCookie.cookies(
    withResponseHeaderFields: httpResponse.allHeaderFields as! [String: String],
    for: url)
/*:
 Из примера выше видно что на вход метод берет заголовки ответа, и `URL`, адрес, для которого мы хотим получить cookie.
 Ответ может содержать cookie для разных доменов и путей.
 */
cookies.first!
/*:
 Для следующего запроса нам тоже не обязательно вручную составлять строку.
 */
var request2 = URLRequest(url: url)

let fields: [String: String] = HTTPCookie.requestHeaderFields(with: cookies)

fields.forEach { (field: String, value: String) in
    request2.setValue(value, forHTTPHeaderField: field)
}

request2.addValue("1", forHTTPHeaderField: "Cookie")
request2.allHTTPHeaderFields!["Cookie"]

request2.allHTTPHeaderFields!["Cookie"]
/*:
 Как видно cookie были добвлены в заголовки запроса не по клюучу `Set-Cookie`, а по `Cookie`.
 Да и добавлено было только имя cookie и его значение. Остальные поля не были добавлены.
 Это выжные нюансы, которые нужно помнить при ручной работе с cookie, либо использовать стандартный `HTTPCookie`, чтобы он все сделал сам.
 
 Можно создать инстанс `HTTPCookie` и привычным способом через `init`
 
 Из сигнатуры инициализатора становится понятно, что `HTTPCookie`, всего лишь удобная обертка над словарем.
 
 Есть среди этих ключей есть и обязательные:
 - name
 - domain (or orginURL)
 - path
 - value
 */
let cookieProperties: [HTTPCookiePropertyKey: Any] = [
    .name: "NID",
    .domain: ".google.ru",
    .path: "/",
    .value: "xxx-xxx"
]
let cookie = HTTPCookie(properties: cookieProperties)!

cookie
/*:
 Ко всем занчениям из словаря можно получить удобный доступ через свойства.
 */
cookie.name
cookie.domain
cookie.path
cookie.value
/*:
 Либо можно получить весь оригинальный словарь.
 */
cookie.properties
/*:
 ## Hould set Cookies?
 
 Надеюсь вы помните что `URLSession`, была создана чтобы управлять состоянием сетевых подключений.
 А cookie как раз один из таких случаев.
 
 Нам не нужно вручную доставать cookie из ответов, а потом самим их вставлять в запросы.
 Все это за нас сделает `URLSession`.
 
 Первое определяет будут ли cookie автоматические добавлятся для каждого запроса из `HTTPCookieStorage`.
 Если вы собираетесь всегда в ручную управлять cookie, то проставьте это свойство в `false`.
 */
let configuration = URLSessionConfiguration.default

configuration.httpShouldSetCookies

request.httpShouldHandleCookies
/*:
 Это свойство эквивалентно такому же у `URLRequest`
 
 
 ## HTTPCookie.AcceptPolicy
 `AcceptPolicy` - Регулирует примеку cookie из ответов сервера.
 
 - `always` Принимать все cookie
 - `never` Не принимать cookie
 - `onlyFromMainDocumentDomain` Принимать только из `mainDocumentURL` релеватно для браузера.
 */
configuration.httpCookieAcceptPolicy
/*:
 ## HTTPCookieStorage
 
 `HTTPCookieStorage` класс, который инкапуслирует в себе логику по хранению cookie.
 По умолчанию cookie будут сохранятся на диск в sqlite файле.
 */
configuration.httpCookieStorage

let httpCookieStorage = configuration.httpCookieStorage!
/*:
 Как и конфигурация сессии хранилище cookie имеет свойство с политикой приемки.
 */
httpCookieStorage.cookieAcceptPolicy
/*:
 `HTTPCookieStorage` проще рассматривать как словарь в котором ключом может выступать `URLSessionTask`, а значением `HTTPCookie`.
 */
let dataTask = URLSession.shared.dataTask(with: URLRequest(url: httpResponse.url!))
/*:
 Так мы можем записать массив cookie для задачи сессии.
 */
httpCookieStorage.storeCookies(cookies, for: dataTask)
/*:
 А позже асинхроно получить доступ к записанным cookie.
 
 Совсем не обязательно использовать один и тот же `URLSessionTask`. Внутри от нас скрыта логика по определению того, какие cookie для какого URL можно проставлять.
 */
httpCookieStorage.getCookiesFor(dataTask, completionHandler: { (cookies: [HTTPCookie]?) in
    cookies
    print(cookies.debugDescription)
})
/*:
 Ещё остались старые синхронные методы доступа и установки `cookie`, делающим похожим поведение хранилища на массив.
 Но я бы рекоменовал использовать новое асинхронное API c `URLSessionTask`.
 
 Поумолчанию используется синглтон `HTTPCookieStorage`, кроме `URLSessionConfiguration.ephemeral`.
 */
URLSession.shared.configuration.httpCookieStorage === HTTPCookieStorage.shared
URLSessionConfiguration.default.httpCookieStorage === HTTPCookieStorage.shared
URLSessionConfiguration.ephemeral.httpCookieStorage === HTTPCookieStorage.shared
/*:
 Может получится так, что у вас есть несколько приложений, у которых есть общий контейнер с данными. И вам бы хотелось чтобы у всех приложений были общие cookie.
 В iOS у каждого приложения есть тоько его cookie и нет доступа к чужим.
 Но для приложений от одного производителя есть возможность получить доступ к общим cookie для них, по идентификатору общего контейнера
 
 `HTTPCookieStorage.sharedCookieStorage(forGroupContainerIdentifier: "com.example.SahredContainer")`
 
 
 Но никто не мешает создать своего наследника `HTTPCookieStorage`, например чтобы сохранять cookie от вашего сервера в `Keychain`.
 
 Создадим в качестве примера `MyCookieStorage`, который будет сохранять только последние cookie в свойство `secretCookie`.
 
 Это помоежт нам залогировать работу `URLSession` c хранилищем cookie.
 */

final class MyCookieStorage: HTTPCookieStorage {
    
    private(set) var secretCookie: [HTTPCookie]?
    
    override func storeCookies(_ cookies: [HTTPCookie], for task: URLSessionTask) {
        self.secretCookie = cookies
        print("store cookie", cookies)
        super.storeCookies(cookies, for: task)
    }
    
    override func getCookiesFor(_ task: URLSessionTask, completionHandler: @escaping ([HTTPCookie]?) -> Void) {
        super.getCookiesFor(task, completionHandler: { cookies in
            print("get cookie", cookies ?? [])
            completionHandler(self.secretCookie)
        })
    }
}
/*:
 И проверим как все работает вместе на примере двух запросов
 */
let cookieStorage = MyCookieStorage()
configuration.httpCookieStorage = cookieStorage

let sessionManager = SessionManager(
    configuration: configuration,
    delegate: AsyncSessionDelegate())
/*:
 Создадим два одиноковых запроса на один и тот же `URL`.
 Исходят из спецификации HTTP у наших запросов не должно быть состояния,
 то есть они должны быть абсолютно одинаковыми и ответы на них должны быть идентичными.
 Но у нас усть cookie, чтобы обойти это.
 */
let dataRequest1 = sessionManager.dataRequest(with: request)
let dataRequest2 = sessionManager.dataRequest(with: request)

dataRequest1.completionHandler = { _ in
    dataRequest1.metrics
    cookieStorage.secretCookie
    
    let transaction1 = dataRequest1.metrics.transactionMetrics[0]
    transaction1.request.url
    transaction1.request.allHTTPHeaderFields?["Cookie"]
    (transaction1.response as! HTTPURLResponse).allHeaderFields["Set-Cookie"]
    
    let transaction2 = dataRequest1.metrics.transactionMetrics[1]
    transaction2.request.url
    transaction2.request.allHTTPHeaderFields?["Cookie"]
    (transaction2.response as! HTTPURLResponse).allHeaderFields["Set-Cookie"]
    
    dataRequest2.dataTask.resume()
}

dataRequest1.dataTask.resume()
/*:
 Отправим первый запрос. По метрике можно увидеть, что сайт google.com не вернул на первый запрос cookie, а только лишь перенаправил наш запрос на другой URL, и в ответе на него венул cookie.
 */
dataRequest2.completionHandler = { _ in
    dataRequest2.dataTask
    dataRequest2.metrics
    
    let transaction1 = dataRequest2.metrics.transactionMetrics[0]
    transaction1.request.url
    transaction1.request.allHTTPHeaderFields?["Cookie"]
    (transaction1.response as! HTTPURLResponse).allHeaderFields["Set-Cookie"]
    
    let transaction2 = dataRequest2.metrics.transactionMetrics[1]
    transaction2.request.url
    transaction2.request.allHTTPHeaderFields?["Cookie"]
    (transaction2.response as! HTTPURLResponse).allHeaderFields["Set-Cookie"]
    
    PlaygroundPage.current.finishExecution()
}
/*:
 Поведение втрого запроса идентично первому. Он также был перенаправлен на другой адре, но подождите! Уже в запросе редиректа имеются cookie, а в ответе их нет.
 
 Если посмотреть вызовы `MyCookieStorage`, мы увидим, что в нем были сохранены cooke, от первого запроса и потом они ушли вместе со втромы.
 
 Надеюсь теперь у вас появилось отчетливое представление, того как `URLSession` работает с cookie, и тепреь у вас не возникнет сложностей, чтобы использовать их своих приложениях.
 */
/*:
 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */
