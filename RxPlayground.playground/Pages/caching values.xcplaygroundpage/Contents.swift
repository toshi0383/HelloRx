//: [Previous](@previous)

import Foundation
import RxSwift
import RxCocoa

func now(_ label: Int) -> String {
    let date = Date()
    let calendar = NSCalendar.current
    let components = calendar.dateComponents([.nanosecond], from: date)
    return "([event \(label)] \(components.nanosecond!))"
}

func create(delayEvents: Int? = nil) -> Observable<String> {
    let o = Observable<String>.create { observer in
        print("run")
        Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance)
            .skip(1)
            .take(5)
            .map(now)
            .bindTo(observer)
        return Disposables.create()
    }
    if let delay = delayEvents {
        return o.delay(RxTimeInterval(delay), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
    } else {
        return o
    }
}
func log<T>(_ identifier: String) -> (Event<T>) -> () {
    return { event in
        switch event {
        case let .next(value):
            print("[observer \(identifier)]", "NEXT", value)
        case .error:
            print("[observer \(identifier)]", "ERROR")
        case .completed:
            print("[observer \(identifier)]", "COMPLETED")
        }
    }
}

do {
    let input = PublishSubject<Int>()
    let output = Variable<Int>(0)
    let lastInput = Variable<Int>(0)

//    _ = input.delay(1, scheduler: MainScheduler.instance).bindTo(lastInput)
    _ = input.bindTo(lastInput)
    _ = input.map { $0 * 10 }.bindTo(output)
    _ = output.asObservable().withLatestFrom(lastInput.asObservable()) {$0}
        .subscribe(log("1"))
    input.onNext(1)
    input.onNext(2)
}

do {
    let input = PublishSubject<Int>()
    let output = input.map { $0 * 10 }
    _ = output.asObservable().withLatestFrom(input) {$0}
        .subscribe(log("2"))
    input.onNext(1)
    input.onNext(2)
}

do {
    let input = PublishSubject<Int>()
    let output = Variable<Int>(0)
    let lastInput = Variable<Int>(0)
    _ = input.map { ($0, $0 * 10) }.subscribe(onNext: {
        lastInput.value = $0
        output.value = $1
    })
    _ = output.asObservable().withLatestFrom(lastInput.asObservable()) {$0}
        .subscribe(log("3"))
    input.onNext(1)
    input.onNext(2)
}


//: [Next](@next)
