/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # URLSessionStreamTask
 
 Вот и дошла очередо до самой редкой задачи сессии `URLSessionStreamTask`.
 Она позволяет отправлять и получать бинарные данные.
 
 HTTP это текстовый протокол работающий поврех tcp. `URLSessionStreamTask` в отличие от остальных задач сессии работает не с HTTP а с tcp. То есть на уровень ниже.
 
 Эта задача может помочь вам в работе, если у вас на сервере реализован свой бинарный протокол, либо если вы занимаетесь интернетом вещеей и соединяетсь с бытовоыми устройствами. У многих из них свой бинарный протокол.ы
 
 Давайте в качестве примера наберем в терминале эту команду.
 
     $ echo -n "Hello client" | nc -l 1234
 
 > Её нужно перезапускать после каждого обновления страницы Playground.
 > Чтобы остановить нажмите `ctrl + C`.
 
 Как и все задачи `URLSessionStreamTask` создается сессией и имеет своего делегата `URLSessionStreamDelegate`.
 */
import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

final class SessionStreamDelegate: NSObject, URLSessionStreamDelegate {}

let session = URLSession(
    configuration: .default,
    delegate: SessionStreamDelegate(),
    delegateQueue: .main)
/*:
 ## Create
 
 Для создания `URLSessionStreamTask` нам может понадобится имя хоста и порт либо `NetService`.
 
 1) Host name and port
 2) NetService
 */
let streamTask = session.streamTask(withHostName: "localhost", port: 1234)

streamTask.resume()
/*:
 ## Writing
 
 После запуска задачи мы можем записывать в нее данные, передав время таймаута и замыкание.
 */
let message = "Hello server"
let data = message.data(using: .utf8)!

streamTask.write(data, timeout: 6, completionHandler: { (error: Error?) in
    if let error = error {
        print("Fail send message: '\(message)' with \(error)")
    } else {
        print("Success send message: '\(message)'")
    }
})
/*:
 Если вы запустили в терминале скрипт то он распечатает вам сообщение.
 Если нет, то `completionHandler` вернется ошибка.
 
 
 ## Reading
 
 Помимо записи можно и читать из `URLSessionStreamTask`, указав минимальный и максимальный размер ответа, а также таймаут и замыкание.
 */
streamTask.readData(ofMinLength: 8, maxLength: 1024, timeout: 6, completionHandler: {
    (data: Data?, eof: Bool, error: Error?) in
    
    print("End of file: \(eof)")
    
    if let error = error {
        print("Fail read data with \(error)")
    } else if let data = data {
        let response = String(data: data, encoding: .utf8)!
        print("Success read response '\(response)'")
    }
})
/*:
 В отличие от замыкания на запись, где могла вернуться ошибка, в замыкании на чтение приходят бинарные данные, флаг и конце чтения (end of file) и ошибка чтения.
 
 
 ## Legacy Stream
 
 `URLSessionStreamTask` - новое API. До него работать с tcp можно было в основном через `InputStream` и `OutputStream`.
 
 После того как `URLSessionStreamTask` установила соединение, можно вызвать метод `captureStreams`, который через метод делегата задачи вернет `InputStream` и `OutputStream`. И вы сможете работать со старой API.
 */
func captureStreams() {
    streamTask.captureStreams()
}

extension SessionStreamDelegate {
    
    func urlSession(
        _ session: URLSession,
        streamTask: URLSessionStreamTask,
        didBecome inputStream: InputStream,
        outputStream: OutputStream) {
        
        // capture steams
    }
}
/*:
 ## Close
 
 `URLSessionStreamTask` имеет внутри себя каналы на чтение и на запись. Каждый из них можно закрыть вызвав ссответсвующий метод.
 
 После него уже нельзя будет записыватьь либо читать из задачи. Эти методы будут возвращать ошибку в замыкании при их вызове.
 */
func close() {
    streamTask.closeRead()
    streamTask.closeWrite()
}
/*:
 После закрытия чтения или записи будут вызваны ссответсвующие методы делегата.
 
 Эти же методы могут быть вызваны не только после того как вы сами закрыли запись или чтение, но и после того как вызовы этих методов завершились ошибкой.
 
 Например если вы попыталсись записать данные, но замыкание вернуло ошибку, то запись может закрыться, и вы узнаете это в методе `urlSession(_:writeClosedFor:)`.
 */
extension SessionStreamDelegate {
    
    func urlSession(
        _ session: URLSession,
        readClosedFor streamTask: URLSessionStreamTask) {
        
        print(#function)
    }
    
    func urlSession(
        _ session: URLSession,
        writeClosedFor streamTask: URLSessionStreamTask) {
        
        print(#function)
    }
}
/*:
 ## Better Route
 
 Большинство из нас (тех кто читает эту книгу) делают приложения для мобильный девайсов. А их не держат на столах. Их носят с собой дома, на улице, на работе.
 
 Во всех этих местах есть разные сети подключения к интернету и как следствие разная скорость.
 
 Так как `URLSessionStreamTask` достаточно низкоуровневый, то у его делегата есть метод сообщающий нам что появилось новое подключение с болей скоростью.
 
 В нём мы может пересоздать подключение и продолжить работу с большей скоростью.
 */
extension SessionStreamDelegate {
    
    func urlSession(
        _ session: URLSession,
        betterRouteDiscoveredFor streamTask: URLSessionStreamTask) {
        
        // recreate streamTask
    }
}
/*:
 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */
