/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # URLSessionDataTask
 
 Почти все наши запросы к API являются обыкновенными HTTP запросами. Получить данные, отправить данные, все просто и без никаких ухищрений.
 
 Как раз для таких базовых задач был создан `URLSessionDataTask`.
 Это наследник `URLSessionTask` не имеющий ни свойств, ни методов отличих его от своего родителя.
 
 Он создан, чтобы я могли явно выразить наши намерения, что хотим сделать обыкновенный запрос.
 Остальные зачади сессии имеют свои особенности направленые, чтобы оптимизировать наше приложение.
 
 
 ### Create
 
 Создать `URLSessionDataTask` может только `URLSession`.
 */
import Foundation

let session = URLSession(
    configuration: .ephemeral,
    delegate: nil,
    delegateQueue: .main)
/*:
 Для создания задачи нам нужен либо `URL`, ...
 */
let url = URL(string: "https://www.apple.com")!

let dataTask1 = session.dataTask(with: url)
/*:
 ... либо `URLRequest`.
 */
let request = URLRequest(url: url)

let dataTask2 = session.dataTask(with: url)
/*:
 Задачу можно создать и c замыканием, в котором вернется результат выполнения.
 
 Тип замыкания будет одинаковым, не зависимо от того с `URL` или `URLRequest` была создана задача.
 
 В замыкании мы получим тело ответа, метаинформацию об ответе и ошибку выполнения.
 */
let dataTask3 = session.dataTask(with: url, completionHandler: {
    (data: Data?, response: URLResponse?, error: Error?) in
    
    // handle ...
})

let dataTask4 = session.dataTask(with: request, completionHandler: {
    (data: Data?, response: URLResponse?, error: Error?) in
    
    // handle ...
})
/*:
 Замыкания может хватить для большинства наших запросов, но если мы хотим получить больше, нужно использовать `URLSessionDataDelegate`.
 
 `URLSessionDataDelegate` - это протокол наследник `URLSessionTaskDelegate`, который содержит специальные методы, жизенного цикла `URLSessionDataTask`.
 
 Если мы хотим его использовать, то должны реализовать его у делегата нашей сессии.
 */
final class DataTaskDelegate: NSObject, URLSessionDataDelegate {
    
    var responseData = Data()
}

let session2 = URLSession(
    configuration: .ephemeral,
    delegate: DataTaskDelegate(),
    delegateQueue: .main)
/*:
 ## URLSessionDataDelegate
 
 ### Response Body
 
 Пожалуй главная особенность `URLSessionDataTask`, то что в результате её выполнения мы получим тело ответа.
 
 Я надеюсь вы помниите, что ни `URLResponse` ни `HTTPURLResponse` не содержат тело,
 по этому для нас крайне важно знать как его получить.
 
 Получить его можно в методе делегата, который вызывается несколько раз, передавая части тела ответа.
 Мы же в свою очередь должны сложить их воедино.
 */
extension DataTaskDelegate {
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data) {
        
        responseData.append(data)
    }
}
/*:
 ### Cache Response
 
 Есть тип который связывает между собой `URLResponse` и тело ответа, и это `CachedURLResponse`.
 Он предназначен для кеширования ответов сервера.
 
 Закешировать мы можем только `URLSessionDataTask`, а в его делегате можем перехватить `CachedURLResponse` и поменять на другой ответ для кеширования, либо совсем отдать в замыкание `nil`, чтобы ничего не кешировать.
 
 Подробнее о кешировани рассказано в главе [URLCache](Cache).
 */
extension DataTaskDelegate {
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        willCacheResponse proposedResponse: CachedURLResponse,
        completionHandler: @escaping (CachedURLResponse?) -> Void) {
        
        completionHandler(proposedResponse)
    }
}

/*:
 ### Response Meta
 
 С помощью делегата можно обрабаотать не только тело ответа, но и его метаданные представленные `URLResponse` и `HTTPURLResponse`.
 
 В его метод приходят сессия, задача, ответ и замыкание в котрое мы пердаем одно из значений `ResponseDisposition`, определющее как будет обработан ответ.
 
 
 **URLSession.ResponseDisposition**
 
 - `cancel` Отменить загрузку. Эквивалетно `dataTask.cancel()`
 - `allow` Продолжить загрузку.
 - `becomeDownload` Трансформировать задачу в задачу загрузки файла.
 - `becomeStream` Трансформировать задачу в задачу потока байтов.
 
 
 В качетве примера провалидируем статус код ответа сервера и если он не OK (200), то отменим запрос.
 */
extension DataTaskDelegate {
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        if let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200 {
            
            completionHandler(.allow)
        } else {
            completionHandler(.cancel)
        }
    }
}
/*:
 ### Did become... other tasks
 
 Если выбрать `becomeDownload` или `becomeStream`, то задача будет трансформирована в `URLSessionDownloadTask` или `URLSessionStreamTask`.
 
 Новые задачи будут переданы в методах делегата.
 */
extension DataTaskDelegate {
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didBecome downloadTask: URLSessionDownloadTask) {
        
        // capture `downloadTask`
    }
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didBecome streamTask: URLSessionStreamTask) {
        
        // capture `streamTask`
    }
}
/*:
 Подробее об этих типах задач сессии можно прочитать в соотвествующих главах
 [URLSessionDownloadTask](URLSessionDownloadTask) и [URLSessionStreamTask](URLSessionStreamTask).

 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */
