/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # HTTP Cache
 
 Все мы стремимся к тому чтобы наши приложения были оптимизированы. И наши пользователи привыкли и хотят получать доступ к контенту быстро. Но почти вся полезная информация хранится на удаленно сервере и по этому скорость работы начинает зависить и от интернет соединения и от производительности бекенда.
 
 Нам бы могла помочь запись всех ответов в локальную БД и работа через нее. Но это не всегда целесообразно, потому что увеличивается время разарботки приложения за счет синхронизации и настройки БД.
 
 Нам не всегда нужны такие сложные решения, учитывая что есть решения проще. Протокол HTTP описывает механизм кеширования ответов. Настройка и работа с ним крайне проста. И это механизм давно используется в браузерах и имеет хорошую поддержку в `Foundation`.
 
 
 ## HTTP Cache Headers
 
 Основой HTTP кеширования являютя специальные заголовки в запросах и ответах. Ими обмениваются сервер и клиент (iPhone, Safary, тд.) По ним клиент понимает когда записать кеши и когда его использовать, чтобы показать пользователю.
 
 Заголовков и правил работы с ними очень много. Но мы постараемся рассмотреть основыные, с которыми вам чаще всего придется сталкиваться.
 
 
 ## Response Cache Headers
 ```
 Cache-Control: private, must-revalidate, max-age=60
 Last-Modified: Wed, 16 Aug 2017 21:00:00 GMT
 ETag: c4ca4238a0b923820dcc509a6f75849b
 ```
 
 ### Cache-Control
 
 **Cache-Control** - Самый главный заголовок кеширования. В нем описываются основные правила кеширования ответа.
 
 **max-age** - Время в секунда с момента запроса, когда закешированный ответ можно считать актуальным и использовать повторно. 
 ```
 600 = 10 мин * 60 сек.
 ```
 **no-store** - Запрещает клиенту кешировать ответ.
 
 **no-cache** - Кеш можно использовать после проверки изменений, то есть клиенту можно использовать кеш только после отправки запроса с заголовками кеширования и ответа 304. В противном случае он просто скачает новую актуальную информацию.
 
 **public** - Говорит о том что ответ можно закешировать даже если имеется HTTP аутентификация. Эта директива используется редко, потому что наличие max-age уже подразумевает её.
 **private** - Сигнализирует о том, что кеш будет содерать данные относящиеся только к текущему пользователю. Например его данные профиля. В основном эта директива бывает нужна для прослоек на стороне сервера чтобы они не сохраняли у себя кеш.
 
 
 ### Last-Modified
 
 **Last-Modified** - ddsad
 
 
 ### Etag
 
 **Etag** - Сокрщение от Entity tag. Уникальный хеш состояния ресурса. Чеще всего используется MD5. Спомощью него можно проверить был ли изменен ресурс или нет.
 
 
 Не обязательно отправлять оба Last-Modified и Etag. Должен быть хотя бы один из них.
 
 
 ## Request Cache Headers
 ```
 If-Modified-Since: Wed, 16 Aug 2017 21:00:00 GMT
 If-None-Match: c4ca4238a0b923820dcc509a6f75849b
 ```
 Если сервер вернет ответ с заголовками кеширования и политикой позволяющей кешировать, то клиент должен сохранить ответ в том числе и **Last-Modified** и **Last-Modified**. При последующий запросах хедеры должны будут содержать If-Modified-Since и If-None-Match. Только по ним сервер сможет понять, что на клиенте имеется кеш опредеить его актуальность и ответить 304, если ресурс не был изменен.
 
 - Last-Modified => If-Modified-Since
 - Etag => If-None-Match
 
 
 # Foundation URL Cache
 
 В iOS уже все готово для работы с кешем. И даже имеются дополнительные возможности, но также и некторые особенности.
 
 - Important:
 У сессии есть одна особенность. Она скрывает от вас ответы 304. И вы получаете в ответе на запрос 200, как будто ответ пришле от сервера а не из кеша.
 
 
 ## URLSessionConfiguration
 
 Первое с чего начинается работа с сетью это сессия и её конфигурация.
 Если использовать синглтон сессиии или конфигурацию по умолчанию, то будет кеш будет работать в соответсвие со спецификацией HTTP cache.
 Если же использоать конфигурацию `ephemeral`, то кеш не будет сохраняться, так как эта конфигурация соответсвует приватному режиму браузера.
 */
import Foundation

let configuration = URLSessionConfiguration.default

let session = URLSession(configuration: configuration)
/*:
 ## Cache Policy
 
 Нам не всегда нужно работаь по спецификации HTTP cache. Для этого во фреймоврке `Foundation` предусмотрена политика кеширования. 
 Это `enum`, значения которого определюят стоит ли возвращать закешированные данные на запрос.
 
 - `.useProtocolCachePolicy`: Обрабатывать заголовки ответов сервера по умолчанию.
 - `.reloadIgnoringLocalCacheData`: Не использовать кеш.
 - `.reloadIgnoringLocalAndRemoteCacheData`: *Не реализован.*
 - `.reloadIgnoringCacheData`: *Тоже самое что и `.reloadIgnoringLocalCacheData`.*
 - `.returnCacheDataElseLoad`: Использовать кеш, либо сделать запрос на сервер, если его нет.
 - `.returnCacheDataDontLoad`: Использовать только локальный кеш.
 - `.reloadRevalidatingCacheData`: *Не реализован.*
 
 > Как вы заметили часть из них не реализована либо ссылается другое значение. Это сделано чтобы зарезервировать значения в `enum`. 
 
 - Experiment:
 Вы можете сделать собственную реализацию для этих политик кеширования имплементируя их в свой `URLProtocol`.
 
 Как и со всеми свойствами сетевых запросов (например таймаут), мы можем настроить политику кеширования в самом запросе либо в конфигурации сессиии.
 */
var request = URLRequest(url: URL(string: "https://google.com")!)
/*:
 Забудем об нереализованных политиках кеширования и сосредоточимся на 4 основных.
 
 По умолчанию используется `.useProtocolCachePolicy`.
 */
request.cachePolicy == .useProtocolCachePolicy
/*:
 Можно сделать запрос без использования кеша `.reloadIgnoringLocalCacheData`.
 */
request.cachePolicy = .reloadIgnoringLocalCacheData
/*:
 Для первого запроса и кеширования ответа подойдет `.returnCacheDataElseLoad`.
 */
request.cachePolicy = .returnCacheDataElseLoad
/*:
 Для работы в оффлайн может пригодится `.returnCacheDataDontLoad`.
 */
request.cachePolicy = .returnCacheDataDontLoad
/*:
 */
let dataTask = session.dataTask(with: request)
dataTask.originalRequest!.cachePolicy == request.cachePolicy
dataTask.currentRequest!.cachePolicy.rawValue

session.dataTask(with: request.url!).originalRequest!.cachePolicy.rawValue
/*:
 ## URLSessionTaskMetrics.ResourceFetchType
 
 У любой задачи сессии есть своя метрика. С её помощью можно узнать тип загрузки контента. 
 
 Если контнте был взят из кеша с помощью `URLRequest.CachePolicy`, то это будет отмечено в ней с типом `.localCache`.
 
 Если кеш был взят после ответа сервера с колом 304, то в метрике будут отмечены два запроса. 
 Один с кодом 304 и типом `.networkLoad` и втрой 200 `.localCache`.
 
 Использование метрики очень сильно поможет вам для дебага сетевых запросов.
 
 
 ## CachedURLResponse
 
 Выдолжны были запомнить что тело ответа и сам класс ответа сервера не связаны друг с другом.
 Для того чтобы записать весь ответ сервера используется класс `CachedURLResponse`, чья основная задача и является обеспечить связть между `URLResponse` и `Data`
 */
let response = HTTPURLResponse(
    url: request.url!,
    statusCode: 200,
    httpVersion: nil,
    headerFields: nil)!

let cachedResponse = CachedURLResponse(
    response: response,
    data: Data(),
    userInfo: nil,
    storagePolicy: .allowed)
/*:
 Дополнительно можно указать словарь `userInfo` и `storagePolicy`.
 
 ### URLCache.StoragePolicy
 
 Определяет можно ли сохранять ответ и в каком виде.
 
 - `.allowed` - Можно сохарнить.
 - `.allowedInMemoryOnly` - Можно сохранить только в память.
 - `.notAllowed` - Нельзя сохранять.
 
 
 ## URLCache
 
 На девайсах Appple весь сетевой кеш харнится в URLCache, который находится в конфигурации сессии.
 По умолчанию в `URLSession.ahared` и во всех новых `URLSessionConfiguration.default` используется синглтон кеша.
 */
URLSession.shared.configuration.urlCache === URLCache.shared
URLSessionConfiguration.default.urlCache === URLCache.shared
/*:
 Совсем не обязательно использовать синглот.
 Можно создать свой инстанс кеша и использовать его в своих сессиях, либо установить в
 */
let cache = URLCache(
    memoryCapacity: 5 * 1024 * 1024,
    diskCapacity: 20 * 1024 * 1024,
    diskPath: nil)

cache.memoryCapacity
cache.diskCapacity
/*:
 Реальные размеры используемой памяти можно также посмотреть.
 */
cache.currentMemoryUsage
cache.currentDiskUsage
/*:
 Можно установить в синглтон свой кеш свой кеше.
 */
URLCache.shared = cache
URLSession.shared.configuration.urlCache === cache
/*:
 Обратите внимание что в `ephemeral` не используется синглтон кеша, так как эта конфигурация эквивалентна по свойствам приватного режима бразуера и не сохраняет данные пользователя.
 */
URLSessionConfiguration.ephemeral.urlCache === URLCache.shared
/*:
 `URLCache` очень сильно похож на словарь, в котором занчения это `CachedURLResponse`, а ключами могут выступать `URLRequest` и `URLSessionDataTask`.
 */
cache.storeCachedResponse(cachedResponse, for: request)
cache.cachedResponse(for: request) === cachedResponse
cache.removeCachedResponse(for: request)
cache.cachedResponse(for: request) == .none
cache.removeAllCachedResponses()
/*:
 Особенным является возможность удалить кеш старше определенной даты.
 */
cache.removeCachedResponses(since: Date())
/*:
 Кеш не является заменой базы данных (хотя под капотом все хранится в sqlite), он предназначем для временного кеширования данных например на день или пару часов. После чего они должны быть удалены.
 
 
 ## URLSessionDataDelegate
 
 На уровне делегата сессии мы всегда можем перехватить `CachedURLResponse`, который может быть закеширован.
 При этом ответ сервера может не соберать заголовков кеширования.
 
 Это может быть полезно в случаях ...
 - Не кешировать определенные ответы серввера
 - Модифицировать заголовки ответа либо их добавить
 
 - Important:
 Этот метод не будет вызван если конфигурация сессии не default и если сервер не вернул ответ с заголовком `Cache-Control: no-store`!
 */
extension DataRequest {
    
    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        willCacheResponse proposedResponse: CachedURLResponse,
        completionHandler: @escaping (CachedURLResponse?) -> Void)
    {
        completionHandler(proposedResponse)
    }
}
/*:
 Недуюсь у вас сложилось полное понимание того как работает HTTP кеширование в iOS и что вы можете использвоать на уровне протокола либо на уровне платформы.
 
 Совсем не обязательно делать локальную БД чтобы уменьшить время время загрузки контента.
 
 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */
