/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # Mocking
 
 Большая часть приложений находящихся в AppStore делает запросы в сеть. 
 Это критически важный функционал приложения!
 Как раз такие элементы приложения нужно покрывать тестами в первую очередь.
 
 *Но как же протестировать сетевые запросы?*
 
 Делать запросы на дев сервер? Такой вариант ставит работу ваших теством в большую зависимость от сервера. 
 К тому же он может быть не доступен, из-за чего остановится ваша работа.
 
 Лучше всего делать моки для сетевых запросо.
 
 В этом нам как раз поможет `URLProtocol`. Он способен перехватить запрос который мы тестируем, и вернуть нам моковый результат.
 Благодаря этому тесты получаться чистыми и мы проверим реузльтаты наших сетвевых запросов с результатом, который ожидали.
 
 ## RouteItem
 
 Чтобы заглушки получились максимально гибки, в начале определим протокол `RouteItem`.
 
 Он будет максимально простым и будет иметь два метода:
 - `equal(to:)` какому сетевому запросу он соотвествует и может обработать.
 - `handle` обработать `URLProtocol`, а в нем уже присутствует вся необходимая информация по запросу в сеть.
 */
import Foundation

public protocol RouteItem {
    
    func equal(to request: URLRequest) -> Bool
    
    func handle(_ urlProtocol: URLProtocol) throws
}
/*:
 Расширим протокол, чтобы он мог делать соотвествие и с `URLSessionTask`, 
 потому что `URLProtocol` фильтруется либо по запросу, либо по задаче.
 */
extension RouteItem {
    
    public func equal(to task: URLSessionTask) -> Bool {
        return task.originalRequest.map(equal) ?? false
    }
}
/*:
 ## Route
 
 Сделаем базовую реализацию протокола `RouteItem`.
 
 `Route` будет содержать навзание метода HTTP и строки которая должна быть в нутри URL запроса,
 с помощью этого можно будет определить какие запросы он может обработать внутри замыкания `handler`, 
 в которое передается `URLProtocol`.
 */
public struct Route {
    
    public let method: String?
    
    public let path: String
    
    public let handler: (URLProtocol) throws -> Void
    
    public init(
        method: String?,
        path: String,
        handler: @escaping (URLProtocol) throws -> Void)
    {
        self.method = method
        self.path = path
        self.handler = handler
    }
}

extension Route: RouteItem {
    
    public func equal(to request: URLRequest) -> Bool {
        return request.httpMethod == method
            && (request.url?.absoluteString ?? "").contains(path)
    }
    
    public func handle(_ urlProtocol: URLProtocol) throws {
        try handler(urlProtocol)
    }
}

/*:
 ## URLMockProtocol
 
 Все моки будут лежать внутри `URLMockProtocol`.
 В нем переопределны методы жизненного цикла `URLProtocol`, 
 чтобы он создавался, только если в нем есть `RouteItem` способный обработать запрос.
 */
open class URLMockProtocol: URLProtocol {
    
    public static var routes: [RouteItem] = []
    
    open class func route(for task: URLSessionTask) -> RouteItem? {
        return routes.first(where: { $0.equal(to: task) })
    }
    
    
    // MARK: - URLProtocol
    
    open override class func canInit(with task: URLSessionTask) -> Bool {
        return route(for: task) != nil
    }
    
    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    private let _task: URLSessionTask?
    
    open override var task: URLSessionTask? {
        return _task
    }
    
    public init(task: URLSessionTask, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        _task = task
        super.init(request: task.originalRequest!, cachedResponse: cachedResponse, client: client)
    }
    
    open override func startLoading() {
        guard let task = self.task else {
            fatalError("Task not found")
        }
        guard let route = type(of: self).route(for: task) else {
            fatalError("Not found route for \(task)")
        }
        do {
            try route.handle(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    open override func stopLoading() {}
}

let route1 = Route(method: "GET", path: "/accounts") { (prot: URLProtocol) in
    let data = Data() // read file
    
    prot.client?.urlProtocol(prot, didLoad: data)
    prot.client?.urlProtocolDidFinishLoading(prot)
}

//
let config = URLSessionConfiguration.default
config.protocolClasses?.insert(URLMockProtocol.self, at: 0)
//

/*:
 
 ```
 class OrganizationServiceTests: XCTestCase {
 
    var bundle: Bundle { return Bundle(for: BasicTestCase.self) }

    var service: OrganizationService!
 
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLMockProtocol.self]
        service = OrganizationService(configuration: configuration)
    }
 
    override func tearDown() {
        URLMockProtocol.routes.removeAll()
        super.tearDown()
    }
 
    func testSearch() {
        let expectation = self.expectation(description: "Поиск организации")
        get("organizations") { try $0.send(["data": ""]) }
 
        let query = OrganizationSearchQuery(title: "гатина", phone: nil)
        _ = service.search(query, completionHandler: { response in
            expectation.fulfill()
            assertMainThread()
            assertNotError(response.error)
            assertNotNil(response.value, "Должны вернуться организации")
        })
 
        waitForExpectations(timeout: 3, handler: nil)
    }
 
 }
 
 extension URLProtocol {
 
    public func send(_ json: [String: Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: json)
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
 
 }
 ```
 
 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */
