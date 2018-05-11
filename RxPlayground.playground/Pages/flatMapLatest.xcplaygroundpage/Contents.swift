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

let firstSlowResponse = create(interval: 1)
let secondFastResponse = create(interval: 0.2)

_ = Observable<Int>.timer(0, period: RxTimeInterval(exactly: 3), scheduler: MainScheduler.instance)
    .take(2)
    .flatMap { num -> Observable<String> in
        if num % 2 == 0 {
            return firstSlowResponse.debug("[firstSlowResponse]")
        } else {
            // trigger firstSlowResponse to get disposed
            return secondFastResponse//.delaySubscription(2.0, scheduler: MainScheduler.instance)
        }
    }
    .subscribe(_log("hello"))
//    .subscribe({ _log("hello")($0) })

RunLoop.main.run(until: Date(timeIntervalSinceNow: 14))

//: [Next](@next)
