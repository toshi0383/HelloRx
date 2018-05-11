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

func create(interval: Double = 1) -> Observable<String> {
    let o = Observable<String>.create { observer in
        print("run by interval: \(interval)")
        Observable<Int>.timer(0, period: interval, scheduler: MainScheduler.instance)
            .skip(1)
            .take(5)
            .map(now(interval: interval))
            .bind(to :observer)
        return Disposables.create()
    }
    return o
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

func emptyObservable() -> Observable<String> {
    return .empty()
}

let observable = Observable.combineLatest(emptyObservable(), create())

class A: NSObject {
    @objc var name: String = "unknown"
}

var a = A()
let name = a.rx.observe(String.self, "name")
name
    .debug("[debug0]")
    .subscribe(_log("log"))
a.name = "ready"
name
    .debug("[debug1]")
    .subscribe(_log("log"))
a.name = "paused"

RunLoop.main.run(until: Date(timeIntervalSinceNow: 14))

//: [Next](@next)

