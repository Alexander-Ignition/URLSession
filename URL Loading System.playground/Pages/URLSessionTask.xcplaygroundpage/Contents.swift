/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # URLSessionTask
 
 Это базывый класс предназначенный для инкапсуляции асинхронного выполнения запроса сеcсии.
 
 От него наследуются все остальные задачи.
 
 - URLSessionTask
    - URLSessionDataTask
        - URLSessionUploadTask
    - URLSessionDownloadTask
    - URLSessionStreamTask
 
 Наследники почти не содержат собственных свойств и методов, по-этому крайне важно знать, что имеется в `URLSessionTask`.
 
 Для примера возьмем `URLSessionDataTask`, так как сам `URLSessionTask` абстрактный класс и сессия его не может создать.
 */
import Foundation

let url = URL(string: "https://api.site.com")!
let task: URLSessionTask = URLSession.shared.dataTask(with: url)
/*:
 Все задачи имеют оригинальный запрос на основе которого они были созданы.
 Кроме `URLSessionStreamTask`, у которого этот запрос равен `nil`.
 */
task.originalRequest
/*:
 Имеется и текущий запрос, чтобы по нему можно было отследить что был редирект запроса.
 */
task.currentRequest
/*:
 ## Response
 
 После выполнения задачи у нее может появится ответ сервера или ошибка выполнения.
 
 - Note:
 Их значения эквивалентны значениям передаваемым в 
 `completionHandler: (Data?, URLResponse?, Error?) -> Void`,
 если создавать задача в сессии вместе с блоком.
 */
task.response
task.error
/*:
 * Important:
 Не смотря на то, что из задачи можно получить ответ сервера или ошибку, она ни как не cвязана с телом ответа.
 
 
 ## Progress
 
 У задач есть проперти для отслеживания прогресс отправки запроса, либо получения ответа.
 - Сколько байтов ожидалось получить и сколько пришло.
 - Сколько байтов ожидалось отправить и сколько отправленно.
 */
task.countOfBytesReceived
task.countOfBytesExpectedToReceive

task.countOfBytesSent
task.countOfBytesExpectedToSend
/*:
 ## ProgressReporting (iOS 11)
 
 Начиная с iOS 11, задача стала реализовывать протокол `ProgressReporting`.
 И вместе с ним у неё появилось свойство с объектом класса `Progress`, через который она оповещает о проценте своего выполнения.
 Благодаря этому нам не нужно самим c помощью KVO наблюдать за изменением свойств отправленых или принятых байт, чтобы отобразить прогресс в UI.
 
 `Progress` - это удобный способ связать ваш UI и асинхронные работы, не сообщая их деталей реализации.
 Подробнее вы можете узнать из [Best Practices for Progress Reporting](https://developer.apple.com/videos/play/wwdc2015/232/)
 */
task.progress
task.progress.localizedDescription
task.progress.fileURL
task.progress.fileOperationKind
/*:
 ## Scheduling Tasks (iOS 11)
 
 Для фоновых сессий у нас появилась возможность запланировать задачу, чтобы она выполнилась не раньше определенной даты.
 Правдва это гарантирует только, что задача начнет выполнение не раньше этой даты! (То есть может начать выполнения позже)
 
 Например можно запланировать её начало после двух часов.
 */
task.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60 * 2)
/*:
 Для оптимизации таких задач мы можем указать максимальный размер, того что планируем получить или отправить.
 
 Верхние границы байтов, которые клиент ожидает
 - Отправить
 - Получить
 */
task.countOfBytesClientExpectsToSend
task.countOfBytesClientExpectsToReceive

/*:
 ## Methods
 
 Так как основное предназначение задачи это инкапсулирование в себе асинхронного выполнения запроса,
 она имеет методы для начала, остановки и отмены запроса.
 
 - Note:
 Не забывайте вызавать метод начала задачи! Иначе запрос не уйдет на сервер.
 */
task.resume()
/*:
 Метод для остановки может пригодится, если хочет загрузить файл позже, 
 тогда можно не отменять задачу, а поставить её на паузу и продлжить с того момента где она остановилась.
 */
task.suspend()
/*:
 + Important:
 Не забывайте отменять задачи, если они уже не нужны.
 Например если пользователь закрыл экран, на котром должен был показаться ответ сервера.
 */
task.cancel()
/*:
 ## State
 
 У задачи есть описание, принимающее четыре состояния
 - Running
 - Suspended
 - Canceling
 - Completed
 
 > `state` поддерживает KVO.
 */
task.state
/*:
 Для удобства отладки задаче можно установить описание, как `Operation.name`
 */
task.taskDescription = "Example task"
task.taskDescription
/*:
 У задачи есть уникальный идентификатор в рамках одной сессии.
 */
task.taskIdentifier
/*:
 Так как задача это абстракция над асинхронным вывполнением, 
 то она имеет приоритет, похожий на Qulity of Service, 
 принимающий значения от 0 до 1.
 
 В `URLSessionTask` имеются три заготовленные константы для него.
 - defaultPriority
 - lowPriority
 - highPriority
 */
task.priority = URLSessionTask.defaultPriority
/*:
 # URLSessionTaskDelegate
 
 Описание задачи было бы не полным без её делегата, который намного расщиряет работу с ней.
 
 Протокол делегата задачи наследуется от `URLSessionDelegate` и не может быть установлен самой задаче.
 Вместо этого делегатом задачи становится делегат сессии. 
 Это связано с тем что сессия гарантирует потоко-безопасность работы с задачами и не может позволить, 
 чтобы делегат задачи был изменен после её создания.
 Это решение кажется спорным на первый взглад, но оно достаточно гибко, 
 чтобы мы могли обрабатывать все задачи одинаково, либо иметь уникальных обработчиков для каждой задачи.
 
 Все наследование можно представить так.
 - URLSessionDelegate
    - URLSessionTaskDelegate
        - URLSessionDataDelegate
    - URLSessionDownloadDelegate
    - URLSessionStreamDelegate
 И оно сильно похоже на наследование от `URLSessionTask`
 */
class TaskDelegate: NSObject, URLSessionTaskDelegate {}
/*:
 Все методы в протоколе `URLSessionTaskDelegate` не обязательные, но один стоит упоминуть в первую очередь.
 Это метод завершения задачи. Он передает ошибку в случае возникших проблем, например "Нет интернета", 
 либо придет `nil` вместо ошибки, что означает успешное выполнение.
 */
extension TaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    }
}
/*:
 ## SSL
 
 Следующим по важности я отметил метод аутентификации.
 
 Он особенно важен при работе с SSL. 
 Из особенностей можно выделить что они принимате замыкание, которое обязательно должно быть вызвано.
 Сигнатура с замыкание позволяет выполнить проверку асинхронно без блокироваки очереди делегата, и вернуть несколько аргументов.
 */
extension TaskDelegate {
    
    func urlSession(_ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        // check SSL
        completionHandler(.performDefaultHandling, nil)
    }
}
/*:
 ## Redirect
 
 Не все редиректы от сервера могут быть полезными.
 Их мы можем перехватить и заменить его на другой, либо вовсе отменив передав `nil` в `completionHandler`.
 Например если пришел редирект на неизвестный хост.
 
 Это метод также ожидает, что наше решение по редиректу может произойти асинхронно.
 */
extension TaskDelegate {
    
    func urlSession(_ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void)
    {
        if task.originalRequest?.url?.host == request.url?.host {
            completionHandler(nil)
        } else {
            completionHandler(request)
        }
    }
}
/*:
 ## Upload stream
 
 Третий асинхронный метод в протоколе задачи, это метод получение нового стрима в тело запроса.
 В основном он может понадобится при отправке файлов на сервер.
 */
extension TaskDelegate {
    
    func urlSession(_ session: URLSession,
        task: URLSessionTask,
        needNewBodyStream completionHandler: @escaping (InputStream?) -> Void)
    {
        completionHandler(nil)
    }
}
/*:
 ## Progress
 
 Прогресс отправки тела запроса можно отслеживать не только через KVO, но и через делегата задачи.
 
 > Интерфейс задачи не заставлет нас использовать прогресс, 
 > но я бы реомедовал начится пользоваться этим классом `Progress`.
 */
extension TaskDelegate {
    
    func urlSession(_ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64)
    {
        //
    }
}
/*:
 ## Metrics (iOS 10)
 
 Для отладки нам очень важно получить всю информацию о запросе, Например такую как все запросы редиректов, время на потраченое на каждом этапе запроса, тип ответа на запрос (кеш, пуш и тд).
 
 Как раз для этого в в iOS 10 была добавлена метрика.
 Её можно получить в методе делегата задачи.
 
 Метрика очень важна для отладки, поэтому ей посвещена отдельная глава [URLSessionTaskMetrics](URLSessionTaskMetrics)
 */
extension TaskDelegate {
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics) {
        
        metrics.taskInterval
        metrics.redirectCount
        
        for transaction in metrics.transactionMetrics {
            transaction.isReusedConnection
            transaction.isProxyConnection
            transaction.resourceFetchType
            // ...
        }
    }
}
/*:
 ## Scheduling Tasks (iOS 11)
 
 Мы уже видели что для фоновых сессия можем создать отложенную задачу, чьё выполнение начнется после запланированной даты.
 
 К тому времени в приложении может много поменяться, например обновится токен, или пользователь выйдет из приложения.
 
 Для того чтобы мы могли обновить запрос или отменить его у делегата задачи будет вызван метод перед началом выполнения отложенной задачи.
 
 В замыкание этого метода мы должны передать одно из значений энума и новый запрос если нужно.
 
 ### DelayedRequestDisposition
 - `.continueLoading` Продолжить загрузку оригинального запроса
 - `.useNewRequest` Использовать новый запрос
 - `.cancel` Отменить
 */
extension TaskDelegate {
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willBeginDelayedRequest request: URLRequest,
        completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        
        completionHandler(.cancel, nil)
    }
}
/*:
 ## Connectivity (iOS 11)
 
 Если ваша сессия настроена для ожидания подклчения к интернету, то было бы хорошо узнать когда определенная задчача не смогла выполнится, из-за отсутсвия интернета и ушла в ожидания.
 
 Как раз для этого есть метод в делегате задачи, который и сообщает об этом.
 */
extension TaskDelegate {
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        //
    }
}
/*:
 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */
