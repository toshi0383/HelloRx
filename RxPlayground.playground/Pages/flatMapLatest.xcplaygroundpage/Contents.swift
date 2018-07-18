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

func test01() {
    let firstSlowResponse = create(interval: 1)
    let secondFastResponse = create(interval: 0.2)

    _ = Observable<Int>.timer(0, period: RxTimeInterval(exactly: 3), scheduler: MainScheduler.instance)
        .take(2)
        .flatMapLatest { num -> Observable<String> in
            if num % 2 == 0 {
                return firstSlowResponse.debug("[firstSlowResponse]")
            } else {
                // trigger firstSlowResponse to get disposed
                return secondFastResponse
            }
        }
        .subscribe(_log("hello"))
}

func test02() {
    let slowResponse = create(interval: 0.7).share()
    let fastResponse = create(interval: 0.4)

    let trigger = Observable
        .merge(slowResponse.take(1),
               slowResponse.skip(1).take(1).delay(0.3, scheduler: MainScheduler.instance))
        .map { _ in }

    _ = trigger
        .flatMapLatest { _ -> Observable<String> in
            return fastResponse.debug("[fastResponse]")
        }
        .sample(trigger.map { _ in }.debug("[sampler]"))
        .subscribe(_log("hello"))
}

test02()

RunLoop.main.run(until: Date(timeIntervalSinceNow: 14))

//: [Next](@next)
