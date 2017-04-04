//
//  ViewController.swift
//  HelloRx
//
//  Created by Toshihiro suzuki on 2017/03/30.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    func now() -> Int {
        let date = Date()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.nanosecond], from: date)
        return components.nanosecond!
    }

    func create(delayEvents: Int? = nil) -> Observable<Int> {
        let o = Observable<Int>.create { observer in
            print("run")
            observer.onNext(self.now())
            observer.onNext(self.now())
            observer.onNext(self.now())
            observer.onNext(self.now())
            observer.onNext(self.now())
            observer.onCompleted()
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
                print("[\(identifier)]", "NEXT", value)
            case .error:
                print("[\(identifier)]", "ERROR")
            case .completed:
                print("[\(identifier)]", "COMPLETED")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        test01()
        test02()
        test03()
        test04()
    }

    func test01() {
        do {
            let o1 = create()
            let replaySubject = ReplaySubject<Int>.createUnbounded()
            _ = o1.bindTo(replaySubject)
            print("bindTo replaySubject")

            _ = replaySubject.subscribe(log("1"))
            _ = replaySubject.subscribe(log("2"))
            _ = replaySubject.subscribe(log("3"))
            _ = replaySubject.subscribe(log("4"))
        }
    }

    func test02() {
        do {
            let o2 = create()
            let shared = o2.shareReplayLatestWhileConnected()
            print("shared")

            _ = shared.subscribe(log("a"))
            _ = shared.subscribe(log("b"))
            _ = shared.subscribe(log("c"))
            _ = shared.subscribe(log("d"))
        }
    }

    func test03() {
        do {
            let o3 = create()
            let shared = o3.shareReplay(3)
            print("shared")

            _ = shared.subscribe(log("10"))
            _ = shared.subscribe(log("20"))
            _ = shared.subscribe(log("30"))
            _ = shared.subscribe(log("40"))
        }
    }

    func test04() {
        do {
            let o4 = create(delayEvents: 1)
            let shared = o4.share()
            print("shared")

            _ = shared.subscribe(log("A"))
            _ = shared.subscribe(log("B"))
            _ = shared.subscribe(log("C"))
            _ = shared.subscribe(log("D"))
            _ = shared.subscribe(log("E"))
        }
    }
}

