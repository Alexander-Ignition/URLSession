/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # Session Manger
 
 
 ## URLSesion
 
 В предыдущих главах мы планомерно знакомились со всеми классами работающими вместе с `URLSession`.
 
 Их взаимодействие и наследование изображено на схеме ниже.
 
 ![URLSession](url_session.png)
 
 - *Задачи и делегеты находятся в разных черных блоках, а объединяет их вместе серое пространство сессии.*
 - *Тонкая горизонтальная серая рамка обозначает логическую свзять и отсутсвие свзязи фактической*
 
 На схеме можно выделить, что задачи и их делегаты связаня только через сессию, и нет прямой связи между задачей и её делегатом.
 Во многом эта проблема связана с тем что делегат сессии явзялется и делегатом задач.
 
 Для рещшения этого на понадобятся классы обертки над задачами, являющиеся и делегами задачь.
 Так вся логика по работе с задачей будет находится в одном классе.
 
 
 ## Session Manger
 
 Настало время привести работу с `URLSession` к удобной форме.
 
 Создадим класс `SesssionManger`, который возьмёт на себя задачу управления `URLSession` и распределения вызовов методов её делегата на делегаты конкретных задачь `URLSessionTask`.
 */
import Foundation

final class SessionManager {
    
    let session: URLSession
    
    let sessionDelegate: SessionDelagate
    
    init(configuration: URLSessionConfiguration = .default, delegate: SessionDelagate) {
        self.sessionDelegate = delegate
        self.session = URLSession(
            configuration: configuration,
            delegate: sessionDelegate,
            delegateQueue: sessionDelegate.operationQueue)
    }
}
/*:
 Мы не можем передавать в `init` сразу готовый `URLSession`, иначе мы не сможем установить необходимого делегата, поэтому мы создаем его внутри `init` и выставим наружу зависимость `URLSessionConfiguration` для гибкой настройки класса.
 Swift типо безопасный язык, и поэтому наш `SessionManager` не может стать и делегатом `URLSession`, как в `AFNetworking`. Оно и к лучше, так как поможет разделить отвественности классов.
 
 
 ## SessionDelegate
 
 Для делегата сессии был сделан протокол `SessionDelagate`, который расширяет `URLSessionDelegate`.
 Основной его задачей будет хранение в себе делеготов `URLSessionTaskDelegate` и проксировать на них через себя вызовы методов делагета сессии. Для этого менеджеру сессии нужно будет знать, что у объектов реализующих протокол `SessionDelagate` есть метод для установки делегатов `setDelagate(_:for:)`.
 
 Также в него мы добавили `OperationQueue`, которая станет `URLSession.delegateQueue` - очередью на, которой вызываются все методы делегата сессии. Это поможет `SessionDelagate` контролировать потоко-безопасность доступа к делегатам задач.
 */
protocol SessionDelagate: URLSessionDelegate {
    
    var operationQueue: OperationQueue { get }
    
    func setDelagate(_ delegate: URLSessionTaskDelegate, for task: URLSessionTask)
}
/*:
 Так как перед нами не стоит цель создания библиотеки для работы с `URLSession`, а всего лишь понимание работы с ней (которое помогло бы вам сделать такую библиотеку). Мы рассмотрим основную связку `URLSessionDataTask + URLSessionDataDelegate`.
 
 Добавим в наш менеджер метод для создания задачи и установки делегата для нее. Здесь мы создаем `dataTask` из сессии, устанавливаем его в `sessionDelegate` и возвращаем его. Достаточно простой пример, но не слишком удобный.
 */
extension SessionManager {
    
    func dataTask(with request: URLRequest, delegate: URLSessionDataDelegate) -> URLSessionDataTask {
        let dataTask = session.dataTask(with: request)
        
        sessionDelegate.setDelagate(delegate, for: dataTask)
        
        return dataTask
    }
}
/*:
 ## Tasks and delegates
 
 Лучше будет если мы инкапсулируем связь между задачи и её делегатом в класс. Так будет нагляднее и мы не запутаемся в наследования делегата сессии.
 
 
 ### TaskDelegate
 
 Так как `URLSessionTask` - базовый класс для все задач, а `URLSessionTaskDelegate` базовый протокол для всех делегатов задачь, то создадим класс `TaskDelegate`, реализующий этот протокол и имеющий поле с этой задачей.
 */
class TaskDelegate: NSObject, URLSessionTaskDelegate {
    
    let task: URLSessionTask
    
    init(task: URLSessionTask) {
        self.task = task
        super.init()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        fatalError("abstract")
    }
}
/*:
 В нем мы добавили главный метод для всех делегатов задачь, говорящий о том, что задача заврешилась и произошла ли ошибка во время её выполнения.
 Не забывайте, что в протоколе остались методы сбора метрики, прогресс отправки, редирект запросов и другие.
 Все они могли бы помочь вам в работе и доступны они только как методы делегата.
 
 - Important:
 Помните, что ошибка приходящая в методе `urlSession(_:task:didCompleteWithError:)`, так же появляется и в проперти самой задачи.

 
 ### DataTaskDelegate
 
 Унаследуемся от `TaskDelegate`, чтобы наш наследник работал с `URLSessionDataTask` и имплементировал протокол `URLSessionDataDelegate`.
*/
final class DataTaskDelegate: TaskDelegate, URLSessionDataDelegate {
    
    let dataTask: URLSessionDataTask
    
    init(dataTask: URLSessionDataTask) {
        self.dataTask = dataTask
        super.init(task: dataTask)
    }
    
    
    private(set) var data = Data()
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.data.append(data)
    }
    
    
    var completionHandler: ((DataTaskDelegate) -> Void)?
    
    override func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        completionHandler?(self)
    }
    
}
/*:
 Основным методом (но не обязательным), в протоколе `URLSessionDataDelegate` является метод получения бинарных данных, где мы прибавляем их к уже полученным ранее.
 
 - Important:
 Метод `urlSession(_:dataTask:didReceive:)` может вывзываться несколько раз с разными частями бинарных данных.
 
 Сейчас мы уже можем добавить в менеджер метод для создания делегата для нашей задачи.
 */
extension SessionManager {
    
    func dataTaskDelegate(with request: URLRequest) -> DataTaskDelegate {
        let dataTask = session.dataTask(with: request)
        let dataTaskDelegate = DataTaskDelegate(dataTask: dataTask)
        
        sessionDelegate.setDelagate(dataTaskDelegate, for: dataTask)
        
        return dataTaskDelegate
    }
}
/*:
 ## SessionDelegate implements
 
 Мы уже разобрались с основами создания делегатов задачь. Насталоа время приступить к имплементации нашего протокола `SessionDelegate`.

 
 ### BasicSessionDelegate

 Сделаем самую простую реализацию `SessionDelegate`, рассчитанную на работу в главном потоке.
 Для этого установим в `operationQueue` очередь главного потока. `SesssionManager` установит её в `URLSesssion` и методы делегата будут вызываться на главном потоке.
 
 Весь "секрет" делегата сессии будет заключаться в том что он хранит делегатов для каждой задачи в словаре, где ключом выступает уникальный идентификатор задачи.
 
 - Important:
 Уникальность идентификатора задачи гарантируется в рамках одной сессии!
 
 Для доступа к этому словарю мы сделаем `subscript`, чтобы нельзя было установить любой `Int`, вместо `URLSessionTask.taskIdentifier`.
 */
class BasicSessionDelegate: NSObject, SessionDelagate {
    
    private var delegates: [Int: URLSessionTaskDelegate] = [:]
    
    subscript(task: URLSessionTask) -> URLSessionTaskDelegate? {
        get {
            return delegates[task.taskIdentifier]
        }
        set {
            delegates[task.taskIdentifier] = newValue
        }
    }
    
    var operationQueue = OperationQueue.main
    
    func setDelagate(_ delegate: URLSessionTaskDelegate, for task: URLSessionTask) {
        self[task] = delegate
    }
}
/*:
 Добавим методы завершения задачи и получения бинарных данных. Их мы будем вызвать на делегатах.
 
 В идеале нужно реализовать все методы делегатов сессиии, а то они не будут вызываться у делегатов задач, если они их не реализуют, но так как это обучающий пример ограничимся методами, которые уже есть в наших делегатах задач.
 */
extension BasicSessionDelegate: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self[task]?.urlSession?(session, task: task, didCompleteWithError: error)
        self[task] = nil
    }
}
extension BasicSessionDelegate: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let dataDelegate = self[dataTask] as? URLSessionDataDelegate else { return }
        dataDelegate.urlSession?(session, dataTask: dataTask, didReceive: data)
    }
}
/*:
 ### ConcurrentSessionDelegate

 Выносить работу с сетью в главный поток не самый лучший пример, учитывая что почти все приложения отправляют десятки запросов, то это пагубно может отразится на отрисовки пользовательского интерфейса.
 
 Создадим потоко безопасного наследника делегата сессии, в котором доступ к делегатам задач будут защищен `NSLock`, а вызовы методов делегата сессии будут происходить в очереди утилит.
 
 * Note:
 Вам не обязательно использовать `NSLock`, вы можете попробовать использовать другие типы lock'ов для повышения эффективности.
 */
final class ConcurrentSessionDelegate: BasicSessionDelegate {
    
    private let lock = NSLock()
    
    override subscript(task: URLSessionTask) -> URLSessionTaskDelegate? {
        get {
            lock.lock(); defer { lock.unlock() }
            
            return super[task]
        }
        set {
            lock.lock(); defer { lock.unlock() }

            super[task] = newValue
        }
    }
    
    override init() {
        super.init()
        operationQueue = OperationQueue()
        operationQueue.qualityOfService = .utility
    }
    
}
/*:
 ## Usage
 
 Настало время проверить нашего менеджера.
 */
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

let sessionManager = SessionManager(
    configuration: .default,
    delegate: BasicSessionDelegate())

let request = URLRequest(url: URL(string: "https://google.com")!)
let dataTaskDelegate = sessionManager.dataTaskDelegate(with: request)

dataTaskDelegate.completionHandler = { (delegate: DataTaskDelegate) in
    if let error = delegate.dataTask.error {
        print(error)
    } else if let string = String(data: delegate.data, encoding: .windowsCP1251) {
        print(string) // html string
    }
}
dataTaskDelegate.dataTask.resume()
/*:
 Разберем все по шагам:
 1. Создаем менеджера
 2. Создадим запрос на сервер
 3. Создадим делегата задачи сессии
 4. Устанавливаем обработчика завершения задачи
 5. Не забываем запустить задачу.
 
 * Note:
 Для того чтобы playground дождался ответа от сервера нужно включить бесконечное выполнений страницы `PlaygroundPage.current.needsIndefiniteExecution = true`.
 
 В результате всех усилий мы получили те же данные, что и при создании задачи с замыканием.
 
 *Для чего же мы написали так много кода?*
 
 **У нас получился каркас, с помощью которого мы легко можем работать с делегатом задачи.
 Подставлять или получать значения из вызовов его методов.**
 
 - Experiment:
 Добавьте метод делегата задачи по сбору метрики запроса в `TaskDelegate` и `BasicSessionDelegate`.
 После этого вы сможете в `completionHandler`, распечатать метрику `URLSessionTaskMetrics`.
 ```
 class TaskDelegate: NSObject, URLSessionTaskDelegate {
    // ...
 
    private(set) var metrics: URLSessionTaskMetrics?
 
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        self.metrics = metrics
    }
 }
 
 extension BasicSessionDelegate: URLSessionTaskDelegate {
    // ...
 
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        self[task]?.urlSession?(session, task: task, didFinishCollecting: metrics)
    }
 }
 ```
 
 ## Conclusion
 
 Теперь вы знаете как нужно работать с делегатами сессии, чтобы они не были для вас проблемой, а стали вашими помощниками.
 
 Надеюсь полученные навыки помогут вам обходится без внешних зависимостей, если ваше приложение отправляет один запрос на сервер, либо помогут вам стать контрибютером opensource библиотек таких как `AFNetworking` и `Alamofire`.
 
 Но главное все же понимание, того как вызовы методов одного делегатата перебрасываются на делегаты конкретных задач. 
 Это поможет вам в написание сложных приложений для работы с сетью. Например для обмена сообщениями tcp или websocket.
 
 
 ## Challenges
 
 * Callout(Challenge):
 Реализуйте все методы из протокола `URLSessionTaskDelegate` в `TaskDelegate`. Не забудьте их добавить и в `BasicSessionDelegate`.
 
 * Callout(Challenge 2):
 Реализуйте все методы из протокола `URLSessionDataDelegate` в `TaskDelegate`. Не забудьте их добавить и в `BasicSessionDelegate`.
 
 + Callout(Challenge 3):
 Попробуйте создать делегата сессии с неблокирующим доступом к делегатам задачь, использовав последовательную очередь.
 
 * Callout(Challenge 4):
 Создайте класс `UploadTaskDelegate` для свзяи `URLSessionUploadTask` и `URLSessionDataDelegate` аналогичный классу `DataTaskDelegate`.
 
 + Callout(Challenge 5):
 Создайте класс `DonwnloadTaskDelegate` для свзяи `URLSessionDownloadTask` и `URLSessionDownloadDelegate` аналогичный классу `DataTaskDelegate`.
 
 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */
