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

    func create() -> Observable<Int> {
        return .create { observer in
            print("run")
            observer.onNext(100)
            observer.onNext(200)
            observer.onNext(300)
            observer.onNext(400)
            observer.onNext(500)
            observer.onCompleted()
            return Disposables.create()
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

        let o1 = create()

        do {
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

        let o2 = create()
        do {
            let shared = o2.shareReplayLatestWhileConnected()
            print("shared")

            _ = shared.subscribe(log("a"))
            _ = shared.subscribe(log("b"))
            _ = shared.subscribe(log("c"))
            _ = shared.subscribe(log("d"))
        }
    }

    func test03() {

        let o3 = create()
        do {
            let shared = o3.shareReplay(3)
            print("shared")

            _ = shared.subscribe(log("10"))
            _ = shared.subscribe(log("20"))
            _ = shared.subscribe(log("30"))
            _ = shared.subscribe(log("40"))
        }
    }

    func test04() {

        let o4 = create()
        do {
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

