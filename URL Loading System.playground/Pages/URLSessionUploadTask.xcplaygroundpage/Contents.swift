/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # URLSessionUploadTask
 
 `URLSessionUploadTask` - это наследник `URLSessionDataTask`, а не `URLSessionTask` в отличие от остальных задачь.
 И он почти ничем не отличиается от `URLSessionDataTask` разве что тем, что он оптимизирован для выгрузки больших файлов на сервре.
 
 ## Creata
 
 Для его создания сессиии нужно передать не только `URLRequest` но и тело запроса.
 Хотя `URLRequest` уже имеет свойства для тела, для `URLSessionUploadTask` его нужно передать явно, видимо чтобы внутри могла быть произведена оптимизация.
 */
import Foundation

let url = URL(string: "https://api.example.com/photos")!
var request = URLRequest(url: url)
let session = URLSession.shared
/*:
 Самый простой способ создать с помощью `URLRequest` и `Data`.
 */
let photoData = Data()
let uploadTask1 = session.uploadTask(with: request, from: photoData, completionHandler: {
    (data: Data?, response: URLResponse?, error: Error?) in
    
    // handle response
})
/*:
 `Data` могла бы лежать в проперти `URLRequest`, но путь до файла туда уже не положить.
 
 Второй способ создания как раз может помочь нам в этом.
 
 Благодаря ему файл не будет загружен в оперативную память а останется на диске пока задача не будет запущена.
 К тому же файл может быть прочитан не полностью а по кускам, что также здорово, если он занимает несколько сотен магабайт.
 */
let fileURL = URL(fileURLWithPath: "/example.jpg")
let uploadTask2 = session.uploadTask(with: request, fromFile: fileURL, completionHandler: {
    (data: Data?, response: URLResponse?, error: Error?) in
    
    // handle response
})
/*:
 Надеюсь вы заметили что параметры замыкание `URLSessionUploadTask` ничем не отличаются от его предка `URLSessionDataTask`.
 
 Конструктором без замыкания всеже больше.
 
 Если первые два такие же как рассмотренные выше. С телом из файла или бинарных данных.
 */
let uploadTask3 = URLSession.shared.uploadTask(with: request, from: photoData)
let uploadTask4 = URLSession.shared.uploadTask(with: request, fromFile: fileURL)
/*:
 То третий конструктор принимает запрос у котрого в свойствах есть `InputStream`.
 */
request.httpBodyStream = InputStream(url: fileURL)
let uploadTask5 = URLSession.shared.uploadTask(withStreamedRequest: request)
/*:
 `InputStream` тела запроса можно подменить в методе делегата `URLSessionTaskDelegate`.
 
 Это может пригодится если запрос долго не стартовал и перед его запуском данные могли изменится.
 */
final class UploadTaskDelegate: NSObject, URLSessionTaskDelegate {
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        
        let inputStream = InputStream(url: fileURL)
        completionHandler(inputStream)
    }
}
/*:
 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */
