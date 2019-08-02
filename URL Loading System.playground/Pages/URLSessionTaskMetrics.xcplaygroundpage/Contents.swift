/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # URLSessionTaskMetrics
 
 `URLSession` и наследники `URLSessionTask` скрывают от нас все сложности сетевого взаимодействия, но порой нам нужно получить делатьное описание того, что произошло в процессе выполнения задачии сессии. Для этого в iOS 10 был добавлен класс `URLSessionTaskMetrics`. Он представляет продробное описание всех метрик задачи.
 
 В основном у метрики есть три поля:
 */
import Foundation
import PlaygroundSupport

let metrics = URLSessionTaskMetrics()
/*:
 1) Интревал дат в которых выполнялась задача.
 */
metrics.taskInterval
/*:
 2) Количество редиректов запроса.
 */
metrics.redirectCount
/*:
 3) Подробные метрики каждого `URLReqest`. 
 Этот массив пуст потому что мы не отправляли никаких запросов через сесиию, а это поле доступно лишь на чтение.
 */
metrics.transactionMetrics
/*:
 ## URLSessionTaskDelegate + URLSessionTaskMetrics
 
 Чтобы получить настоящую метрику задачи, нужно создать сессию и делегата для неё.
 
 Делегатом станет `MetricsDelegate`, которому позже через расширение мы добавим метод получения метрики.
 */
final class MetricsDelegate: NSObject, URLSessionDelegate {}

let session = URLSession(
    configuration: .default,
    delegate: MetricsDelegate(),
    delegateQueue: .main)
/*:
 Для эксперимента создадим запрос к сайту google.
 */
let url = URL(string: "https://google.com")!
let request = URLRequest(url: url)

PlaygroundPage.current.needsIndefiniteExecution = true
let dataTask = session.dataTask(with: request) { _, _, _ in
    PlaygroundPage.current.finishExecution()
}
dataTask.resume()
/*:
 Для получения метрики делегат сессии должен реализовать метод `urlSession(:task:didFinishCollecting:)` из протокола `URLSessionTaskDelegate`.
 */
extension MetricsDelegate: URLSessionTaskDelegate {
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics)
    {
        print(metrics)
        metrics
        metrics.transactionMetrics[0]
        metrics.transactionMetrics[1]
    }
}
/*:
 ## URLSessionTaskTransactionMetrics
 
 Уже на настоящей метрике задачи в примере выше, мы видим что произошел редирект.
 Наш оригинальный запрос `URL: https://google.com/`, был перенаправлен сервером на другой `URL`
 
 Это пожалуй основная и главная осбенность метрик транзакции то, что они показывают какой запрос ушел на сервер и какой ответ вернулся на него.
 
 
 ### Transaction Metrics Date
 
 Метрика транзакции предоставляет полный перечень фиксированных дат наала и конца всех этапов сетевого соединения.
 
 - Fetch Start Date
 - Domain Lookup Start/End Date
 - Connect Start/End Date
 - Secure Connection Start/End Date
 - Request Start/End Date
 - Response Start/End Date
 
 Они могут пригодится в анализе быстродействия бекенда с которым работает ваше мобильное приложение.
 
 
 Помимо свойств с датами есть еще ...
 
 - `networkProtocolName` Название сетевого протокола.
 - `isProxyConnection` Использовалась ли прокси?
 - `isProxyConnection` Было ли переиспользование сетевого подключения. Это может быть важно при болшой объеме запросов
 
 
 ### Resource Fetch Type
 
 Ну и последнее свойство, но ничуть не менее важное это тип получения ресурса
 
 - `unknown` Неизвестный тип.
 - `networkLoad` Загружено по сети. То что мы чаще всего и делаем.
 - `serverPush` Если сервер работает по HTTP2, то он может отправить нам ресурс еще до того как мы его запроси. Хорошо что с помощью метрики мы можем это проверить не переделываю привычные интерфейсы взаимодействия с сессией.
 - `localCache` Ресурс вернулся из кеша.

 
 ## Conclusion

 В заключении я бы хотел осбенно подчернуть то, что если вам становится не понятно какой запрос уходит на сервер и какой ответ приходит от него, то сразу же смотрите метрику задач. Сессия скрывает за собой много сложный вещей таких как редиректы, кеш, куки и тд. Все эти вещи становятся видны как наладоне если смотреть на метрику.
 
 С ней мы будем активно работать в следующих главах про кеширование и куки.
 
 
 ## Challenges
 
 * Callout(Challenge):
 Найдите в ответах сервера куки.
 
 * Callout(Challenge 2):
 Какие заголовки кеширования вернулись в ответах сервера?
 
 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */
