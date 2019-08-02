/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # URLSessionDownloadTask
 
 Пожалйс самая интересная задача сессии. Хоть и большинство наших запросов это просто запросы c JSON,
 но иногда все же нам приходится скачивать файлы.
 
 Например нам может понадоюится скачать фильм или песню в приложении и тут нам попможет `URLSessionDownloadTask`.
 
 `URLSessionDownloadTask` - это наследник `URLSessionTask` предназначенный для загружки файлов.
 
 ## Create
 
 Создание задачи загрузки очень похоже на создание `URLSessionDataTask`.
 */
import Foundation

let session = URLSession.shared
/*:
 Они похожи тем, что их можно с помощью `URL` ...
 */
let url = URL(string: "https://www.apple.com")!

let downloadTask1 = session.downloadTask(with: url, completionHandler: {
    (url: URL?, response: URLResponse?, error: Error?) in
    
    // copy file at location
})
/*:
 ... либо с `URLRequest`.
 */
let request = URLRequest(url: url)

let downloadTask2 = session.downloadTask(with: request, completionHandler: {
    (location: URL?, response: URLResponse?, error: Error?) in
    
    // copy file at location
})
/*:
 Третий конструктор принимает `resumeData`.
 
 *Что за `resumeData`?*
 */
let resumeData = Data()

let downloadTask3 = session.downloadTask(withResumeData: resumeData, completionHandler: {
    (location: URL?, response: URLResponse?, error: Error?) in
    
    // copy file at location
})
/*:
 Все конструкторы c замыканием передают в него первым аргументом `URL`,
 в то время как `URLSessionDataTask` и `URLSessionUploadTask` передавали `Data`.
 
 Это очевидное отличие связано с тем, что `URLSessionDownloadTask` загружает файл по частям,
 которые складывает в один временный файл. В замыкание как раз передается `URL` на него.
 После чего этот временный файл нужно скопировать в нужную вам папку.
 Благодаря загрузки по частям, файл не занимает собой оперативную память а хранится на диске.
 Это позволяет избежать проблем с производительностью, так как файл может быть размером в несколько гигабайт.
 
 Помимо удобных конструкторов с замыкание, как всегда есть их версии без него.
 
 Они принимают точно такие же аргументы: `URL`, `URLRequest` и `resumeData`.
 */
let downloadTask4 = session.downloadTask(with: url)
let downloadTask5 = session.downloadTask(with: request)
let downloadTask6 = session.downloadTask(withResumeData: resumeData)
/*:
 При использовании конструкторов без замыканий мы должны реализовать
 у нашего делегата сессии протокол `URLSessionDownloadDelegate`.

 
 ## URLSessionDownloadDelegate
 
 В отличие от всех делегатов задач, он имеет один обязательный метод.

 Он эквивалентен замыканию в нем также приходит `URL` на временный файл.
 Он обязателен как раз из-за временного файла, так как без копирования этого файла в рабочую папку
 вся загрузка не имела бы смысла, потому что временный файл будет удален через некотрое время.
 */
final class DownloadTaskDelegate: NSObject, URLSessionDownloadDelegate {
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL) {
        
        // copy file at location
    }
}

let session2 = URLSession(
    configuration: .default,
    delegate: DownloadTaskDelegate(),
    delegateQueue: .main)
/*:
 ### Download Progress
 
 В процессе загрузки нам бы хотелось показывать пользователю прогресс.
 Как раз для этого есть второй метод делегата, который говрит о том сколько
 байтов записано, сколько всего записано и сколько ожидается записать.
 
 Но после iOS 11, `URLSessionTask` появиось свойство с `Progress` и в UI можно обойтись только им.
 */
extension DownloadTaskDelegate {
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64) {
        
        // Download Progress
    }
}
/*:
 ### Resume
 
 Последний метод делегата оповещает с какого байта, продолжилась загрузка файла.
 
 *То есть можно продолжить загрузку не с начала?*
 */
extension DownloadTaskDelegate {
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didResumeAtOffset fileOffset: Int64,
        expectedTotalBytes: Int64) {
        
        // Resume at offset
        print("\(downloadTask) resume at \(fileOffset) of \(expectedTotalBytes)")
    }
}
/*:
 ## Resume Download
 
 Для меня `URLSessionDownloadTask` остается самой интересной задачей сессией,
 как раз из-за возмодности прервать а потом продолжить загрзку.
 
 Все задачи можно поставить на `suspend()` а потом возомбновить их `resume()`.
 Но только `URLSessionDownloadTask` позволяет продолжить загрузку после отмены или ошибки.
 
 У `URLSessionDownloadTask` есть метод отмены с замыканием, в которое вернутся специальные бинарные данные.
 (Либо не вернутся если все загружено, либо загрузка еще не началась)
 С помощью них можно потом создать новую задачу загрузки и продолжить её с момента где она остановилась.
 */
downloadTask2.cancel { (resumeData: Data?) in
    guard let data = resumeData else {
        return
    }
    let downloadTask = session.downloadTask(withResumeData: data)
    downloadTask.resume()
}
/*:
 Это все работает с помощью HTTP заголовков ответа.
 Благодаря `resumeData` сессия занет какие нужно передать заголовки,
 которые скажут с какого байта нужно начать отдавать файл.
 
 `resumeData` можно получить не только с и замыкания отмены, но и из ошибки.
 Для этого `resumeData` нужно кастануть на `NSError` и потом из `userInfo`
 по ключу `NSURLSessionDownloadTaskResumeData` достать `resumeData`.
 */
let downloadTask10 = session.downloadTask(with: url, completionHandler: {
    (location: URL?, response: URLResponse?, error: Error?) in
    
    guard let nsError = error as? URLError,
        let resumeData = nsError.userInfo[NSURLSessionDownloadTaskResumeData] as? Data else { return }
    
    print(resumeData)
})
/*:
 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */
