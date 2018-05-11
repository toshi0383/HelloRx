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

// Observable.merge(
//     create()
//     emptyObservable().map { $0 }
//     )
//     .subscribe(_log("hello"))

// Variable
do {
    let variable = Variable("dog")
    var disposeBag = DisposeBag()

    variable.asObservable()
        .subscribe(_log("log1"))
        .disposed(by: disposeBag)
    variable.value = "cat"
    disposeBag = DisposeBag()

    variable.asObservable()
        .subscribe(_log("log2"))
        .disposed(by: disposeBag)
    variable.value = "bird"
    disposeBag = DisposeBag()
    print(variable.value)
}

// replay whileConnected
let sub = PublishSubject<String>()
create()
    .bind(to: sub)
var disposeBag = DisposeBag()
do {
    let replayObservable: Observable<String> = sub
        .share(replay: 1, scope: .whileConnected)
    replayObservable
        .subscribe(_log("log3"))
        .disposed(by: disposeBag)
    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 2.0) {
        disposeBag = DisposeBag()
        replayObservable
            .subscribe(_log("log4"))
            .disposed(by: disposeBag)
    }
}

RunLoop.main.run(until: Date(timeIntervalSinceNow: 14))

//: [Next](@next)
