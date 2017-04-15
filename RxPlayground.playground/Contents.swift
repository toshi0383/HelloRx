//
//  RxPlayground
//  HelloRx
//
//  Created by Toshihiro suzuki on 2017/03/30.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import UIKit
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

//
// share(HOT変換)の話
// - 計算結果が共有される
// - subscribeしなくても動く
//

func test04() {
    do {
        let o4 = create()
        let shared = o4.share()
        print("share()")
        // **When the first observer subscribes to this Observable, RefCount connects to the underlying connectable Observable.**

//        _ = shared.subscribe(log("A"))
//        _ = shared.subscribe(log("B"))
//        _ = shared.subscribe(log("C"))
//        _ = shared.subscribe(log("D"))
        _ = shared
            .do(onSubscribed: {print("subscribed")})
            .delaySubscription(3.5, scheduler: MainScheduler.instance).subscribe(log("*E"))
    }
}

//test04()

func test06() {
    do {
        let o = create()
        let shared = o.publish()
        print("share()")
        shared.connect()

        //        _ = shared.subscribe(log("C"))
        _ = shared
            .do(onSubscribed: {print("subscribed")})
            .delaySubscription(3.5, scheduler: MainScheduler.instance).subscribe(log("*E"))
    }
}

//test06()

//
// Replayの話
//

// ReplaySubjecjt
// - Subject系は全部HOT
// - ReplaySubjectは指定された数だけイベントをキャッシュする
func test01() {
    do {
        let o1 = create()
        let replaySubject = ReplaySubject<String>.createUnbounded()
        replaySubject.onNext("hello (not subscribed but this event is cached)")
        _ = o1.bindTo(replaySubject)
        print("bindTo replaySubject")

        _ = replaySubject.subscribe(log("1"))
        _ = replaySubject.subscribe(log("2"))
        _ = replaySubject.subscribe(log("3"))
        _ = replaySubject
            .do(onSubscribed: {print("subscribed")})
            .delaySubscription(3.5, scheduler: MainScheduler.instance).subscribe(log("*4"))
    }
}

//test01()

// shareReplay(n)
// - Note: shareReplay(n)はnが1の場合とそれ以外とで実装が分かれている.
//      n == 1: ShareReplay1(source: self.asObservable())
//      else  : self.replay(bufferSize).refCount()
// - (どちらもsubscribeしないと動かないみたい)

func test03() {
    do {
        let o = create()
        let shared = o.shareReplay(1)
        print("shareReplay(n)")
//        _ = shared.subscribe(log("10"))
//        _ = shared.subscribe(log("20"))
//        _ = shared.subscribe(log("30"))
        _ = shared
            .do(onSubscribed: {print("subscribed")})
            .delaySubscription(3.5, scheduler: MainScheduler.instance).subscribe(log("*40"))
    }
}

//test03()

// shareReplayLatestWhileConnected()
// - shareReplay(1)とほぼ同じだが、subscriberがいなくなると一度キャッシュがクリアされる
//
//   "Unlike `shareReplay(bufferSize: Int)`, this operator will clear
//    latest element from replay buffer in case number of subscribers 
//    drops from one to zero. In case sequence completes or errors out
//    replay buffer is also cleared."
//

func test02() {
    do {
        let o = create()
        let shared = o.shareReplayLatestWhileConnected()
        print("shareReplayLatestWhileConnected()")

        _ = shared.subscribe(log("a"))
        _ = shared
            .do(onSubscribed: {print("subscribed")})
            .delaySubscription(7, scheduler: MainScheduler.instance).subscribe(log("*d"))
    }
}

test02()

RunLoop.main.run(until: Date(timeIntervalSinceNow: 13))
