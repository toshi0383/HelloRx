//: [Previous](@previous)

import Foundation
import RxSwift
import RxCocoa

func now(interval: Double) -> (_ label: Int) -> String {
    let date = Date()
    let calendar = NSCalendar.current
    let components = calendar.dateComponents([.nanosecond], from: date)
    return { "([now \($0) by interval: \(interval)] \(components.nanosecond!))" }
}


func send() -> Observable<Void> {
    return Single<Void>.create { observer in
        print("send request")
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1) {
            observer(.success(()))
//                observer(.error(error))
        }
        return Disposables.create()
    }.asObservable()
}

func _log<T>(_ identifier: String) -> (Event<T>) -> () {
    return { event in
        switch event {
        case .next(let value):
            print("[observer \(identifier)]", "NEXT", value)
        case .error:
            print("[observer \(identifier)]", "ERROR")
        case .completed:
            print("[observer \(identifier)]", "COMPLETED")
        }
    }
}

struct MyError: Error { }

let o1 = send()
o1.subscribe(_log("YELLOW"))

RunLoop.main.run(until: Date(timeIntervalSinceNow: 14))

//: [Next](@next)


