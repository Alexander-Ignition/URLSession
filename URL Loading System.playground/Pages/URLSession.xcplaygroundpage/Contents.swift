/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # URLSession
 
 Мы долго разбирались с тем что мы можем передать и получить по сети. Настало время разобраться в том что же такое `URLSession`.
 
 URLSesion - это фабрика `URLSessionTask` и его наследников. Она полностью отвечает за их создание, жизненный цикл и обеспечивает потоко безопасность при работе с сетью.
 
 Давайте же рассмотрим как мы можем создать `URLSession`.
 
 ## `URLSession.init`
 
 До этого во всех примерах мы уже использовали общую сессию. Синглтон, который в основном используют в примерах. В настоящих приложениях лучше его не использовать, потому что его нельзя настроить под особенности вашей бизнесс логики.
 */
import Foundation

let sharedSession = URLSession.shared
/*:
 Для собственной сессии Apple дала над два инициализатора. Первый из них просто принимает конфигурацию сессиии.
 
 Она была создана, чтобы свойтсва сессии вынести в отдельный класс, тем самым разгрузив интерфейс самой сессиию. ????
 
 О ней мы еще поговорим подробно.
 */
let configuration = URLSessionConfiguration.default
let mySession = URLSession(configuration: configuration)
/*:
 - Experiment:
 Попробуйте после создания `mySession` изменить проперти у `configuration`.
 Например так: `configuration.timeoutIntervalForRequest = 30`.
 Поменялись ли оно у `mySession.configuration`?
 
 Во втром конструкторе помимо конфигурации можно указать делегата сесиии и очеред, в которой будут вызываться методы делагата очереди.
 Они не обязательные аргументы.
 */
let session = URLSession(
    configuration: configuration,
    delegate: nil,
    delegateQueue: OperationQueue())
/*:
 - Important:
 Конфигурация копируется при передаче её в инициализатор сессии!
 
 В итоге у нас получается три способа получить сессиию:
 1. Синглтон
 2. Инициализатор с конфигурацией
 3. Инициализатор с конфигурацией, делегатом и очередью делегата.
 
 Конфигурация и делегат являются очень важными частями сессии, но они будут подробно рассмотрены в отдельных главах. 
 Сейчас же мы рассмотрим сессию с точки зрения фабрики `URLSessionTask`.
 
 ## Create tasks
 
 Для всех наследников `URLSessionTask` у `URLSession`, есть методы по созданию их. 
 Все они принимают аргументы, которые мы рассмотрели в разделе `Input`.
 
 ### URLSessionDataTask
 
 */
let url = URL(string: "https://api.site.com")!
let request = URLRequest(url: url)

let dataTask1 = session.dataTask(with: url)
let dataTask2 = session.dataTask(with: request)
/*: 
 ### URLSessionUploadTask
 */
let fileURL = URL(fileURLWithPath: "/")
let bodyData = Data()

let uploadTask1 = session.uploadTask(with: request, fromFile: fileURL)
let uploadTask2 = session.uploadTask(with: request, from: bodyData)
let uploadTask3 = session.uploadTask(withStreamedRequest: request)
/*:
 ### URLSessionDownloadTask
 */
let downloadTask1 = session.downloadTask(with: url)
let downloadTask2 = session.downloadTask(with: request)
let downloadTask3 = session.downloadTask(withResumeData: bodyData)
/*:
 ### URLSessionStreamTask
 
 Задача tcp соединения.
 Данные тип задачи был добавлен как новое АПИ, вместо старого основанного на NSStream.
 Имеет ряд особенностей в отличие от остальных задач.
 */
let netService = NetService(domain: "", type: "_music._tcp", name: "", port: 90)

let streamTask1 = session.streamTask(with: netService)
let streamTask2 = session.streamTask(withHostName: "localhost", port: 8080)
/*:
 У всех этих методов есть одна неприятная особенность: для получения результата их выполнения придется создать делегат сессии и ловить в нем, то что пришло в ответ на наш запрос. Но не все так плохо на первы взгляд.
 
 ### NSURLSession (NSURLSessionAsynchronousConvenience)
 
 Сессия имеет категорию с удобными методами для создания задачь с замыканиями без необходимости работы с делагатами. Это намного упрощает работу, но в то же время накладывает ограничения, ввиде того что в замыкания передается лишь минимум той информации, которую можно получить через делегата.
 
 `URLSessionDataTask` и `URLSessionUploadTask` имеют эквивалентные замыкания получающие аргументы:
    `(Data?, URLResponse?, Error?) -> Void`
 */
let dataTask3 = session.dataTask(with: url) {
    (data: Data?, response: URLResponse?, error: Error?) in
    //
}
/*:
 `URLSessionDownloadTask` в замыкании получает `(URL?, URLResponse?, Error?) -> Void`, и отличается лишь тем что первый аргумент `URL` вместо `Data`. Это связанно с тем, что он загружает файл в приложение и возвращает его локальный `URL`, вместо чтения всего файла целиком, что может повлиять на производительность, если файл окажется большого размера.
 */
let downloadTask4 = session.downloadTask(with: url) {
    (url: URL?, response: URLResponse?, error: Error?) in
    //
}
/*:
 URLSessionStreamTask` ввиду своих особенностей не имеет таких методов конструкторов у сессии, но имеет у себя асинхронные методы с замыканиями на чтение и на запись.
 */
streamTask2.readData(ofMinLength: 64, maxLength: 512, timeout: 10) {
    (data: Data?, eof: Bool, error: Error?) in
    // read data
}

streamTask2.write(bodyData, timeout: 10) { (error: Error?) in
    // check error
}
/*:
 - Important:
 Чтобы задача начала выполнения у неё нужно вызвать метод `resume()`!
 
 Суммируя выше приведнные способы создания задач сессиии, можно составить общую схему.
 
 ![URLSession tasks](url_session_task.png)
 
 
 ## Manage tasks
 
 - Note:
 Прежде чем мы продолжи стоит упомниуть о том что у сессии есть `sessionDescription`.
 В это поле можно записать любую строку, которая неприменно пригодится вам в отладке.
 */
session.sessionDescription = "Awesome"
/*:
 Сессия не только ответсвенна за создание задач, но и также за управление ими.
 
 Можно асинхронно получить всеv запущенным задачам.

 - Колбек будет вызван на очереди делегата сессии.
 - `URLSessionStreamTask` всегда будет приходить в колбеке, независимо от того запускался он или нет.
 */
session.getAllTasks { (tasks: [URLSessionTask]) in
    tasks.count
    print(tasks)
}
/*:
 Аналогичным образом работает и метод `getTasksWithCompletionHandler`, только в колбеке вы получите задачи разбитые на три основные типа.
 */
session.getTasksWithCompletionHandler {
    (dataTasks: [URLSessionDataTask], uploadTasks: [URLSessionUploadTask], downloadTasks: [URLSessionDownloadTask]) in
    
    dataTasks.count
    uploadTasks.count
    downloadTasks.count
}
/*:
 > Так как доступ к ним асинхронный, то нужно настроить playground, чтобы он дождался ответа.
 */
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true


/*:
 ### Invalidate
 
 > Так как доступ к ним асинхронный, то нужно настроить playground, чтобы он дождался ответа.
 */

/*:
 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */
