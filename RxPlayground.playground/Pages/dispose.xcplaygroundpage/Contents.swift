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
            .bind(to: observer)
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

var a: Disposable? = create().subscribe(log("1"))
a?.dispose()
a = nil

var d: Disposable? = create().subscribe(log("2"))
d = nil

var b: DisposeBag?
do {
    let disposeBag = DisposeBag()
    create().subscribe(log("3")).disposed(by: disposeBag)
    b = disposeBag
}
b = nil

var c: DisposeBag? = DisposeBag()
create().subscribe(log("4")).disposed(by: c!)
c = nil

// Dispose then relay event

do {
    class AnalyticsStore {
        static let shared = AnalyticsStore()
        let playerDisposed = PublishRelay<Bool>()

        private let disposeBag = DisposeBag()
        private let variable = Variable(false)
        
        private init() {
            playerDisposed
                .debug("[bind to variable]")
                .bind(to: variable)
                .disposed(by: disposeBag)
        }

    }

    class Player {
        let relay = PublishRelay<Bool>()
        private let disposeBag = DisposeBag()

        init() {
            relay
                .subscribe(onNext: {
                    AnalyticsStore.shared.playerDisposed.accept($0)
                })
                .disposed(by: disposeBag)
        }

        deinit {
            relay.accept(false)
        }
    }
    var player: Player? = Player()
//    player = nil
}

RunLoop.main.run(until: Date(timeIntervalSinceNow: 4))

//: [Next](@next)
