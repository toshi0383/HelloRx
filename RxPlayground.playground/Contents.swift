//: Playground - noun: a place where people can play

import UIKit
import RxSwift


import RxSwift

let o = Observable<Int>.create { observer in
    print("run")
    observer.onNext(100)
    observer.onNext(200)
    observer.onCompleted()

    return Disposables.create()
}

func log<T>(_ identifier: String) -> (Event<T>) -> () {
    return { event in
        switch event {
        case let .next(value):
            print("[\(identifier)]", "NEXT", value)
        case .error:
            print("[\(identifier)]", "ERROR")
        case .completed:
            print("[\(identifier)]", "COMPLETED")
        }
    }
}

do {
    let shared = o.shareReplay(3)
    print("shared")

    shared.subscribe(log("1"))
    shared.subscribe(log("2"))
    shared.subscribe(log("3"))
}
/*
 shared
 run
 [1] NEXT 100
 [1] NEXT 200
 [1] COMPLETED
 [2] NEXT 100
 [2] NEXT 200
 [2] COMPLETED
 run
 [3] NEXT 100
 [3] NEXT 200
 [3] COMPLETED
 run
 */


do {
    let shared = o.shareReplay(1)
    print("shared")

    shared.subscribe(log("1"))
    shared.subscribe(log("2"))
    shared.subscribe(log("3"))
}
/*
 shared
 run
 [1] NEXT 100
 [1] NEXT 200
 [1] COMPLETED
 [2] NEXT 200
 [2] COMPLETED
 [3] NEXT 200
 [3] COMPLETED
 */