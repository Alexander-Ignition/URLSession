/*:
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 ****
 
 # Problems
 
 Мы рассмотрели почти все тонкости работы с `URLSession` и столкнулись с вещами, которые нам приходилось делать из раза в раз. Здесь я бы хотел свести их все в один список, чтобы вы могли оценить их все вместе.
 
 - **Ручной запуск `URLSessionTask`**.\
Конечно могут быть сожные случаи, когда этого делать не нужно, но в большинстве нам каждый раз пришлось бы вызывать метод `resume()`. Это очень легко забыть. Будьте внимательны!
 
 - **Сериализация запросов**.\
URLRequest имеет проперти `var httpBody: Data?`, которое позволяет нам положить туда любые бинарные данные, но при этом перекладывает на нас работу по сериализации наших данных.
 
 - **Сериализация ответов**.\
`URLResponse` и его наследник `HTTPURLResponse` не имеют пропертей с данными ответа, по-этому мы их может получить либо в замыкании, либо в методе `func urlSession(_:dataTask:didReceive:)` делагата `URLSessionDataDelegate`. И уже после получения мы можем попытаться сериализовать ответ и получить ожидаемые данные, либо ошибку API от сервера.

 - **Обработка HTTP кодов**\
Во всех колбеках нам возвращается `URLResponse` и его нужно проверять на наследника `HTTPURLResponse`, только из него мы можем получить HTTP status code, и проверить его корректность. Если нам пришел код, который мы не ожидали из него нужно саммим сделать ошибку.

 - **Обработка Ошибок сериализации запросов / ответов**
 
 - **Обработка делегата `URLSessionDelegate`**

 
 
 - **Возможность перезапросов**
 
 - **Выстраивание цепочки запросов**
 
 ****
 [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
 */