//
//  OperatorViewController.swift
//  UseAlamofire
//
//  Created by kede on 2018/10/31.
//  Copyright © 2018 Clare320. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

class OperatorViewController: UIViewController {

    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        testOperator()
    }
    
    func testOperator() -> Void {
        // jsut 创建特定元素的序列
        let zeroObservable = Observable.just(0)
        zeroObservable.subscribe { (e) in
            print(e)
        }.disposed(by: disposeBag)
    
        // timer -- 延时产生唯一的元素 --- 怎么用  -- 产生什么类型的元素
        
        // form 将其它类型转化为Observable 
        let formObservable = Observable.from(["first": "Clare", "second": "Mark"])
        let formDisposable = formObservable.subscribe(onNext: { (item) in
            print(item.key, item.value)
        })
        formDisposable.dispose()
        
        // repeatElement -- 重复产生一个元素
        /*  这段代码直接卡死机器
        let repeatElementDisposable = Observable.repeatElement("Hello Clare320")
            .subscribe(onNext: { (item) in
            print(item)
        })
        
        Thread.sleep(forTimeInterval: 4)
        
        repeatElementDisposable.dispose()
        */
        
        // create --> 自定义Observable
        let customObservable = Observable<Int>.create { (observer) -> Disposable in
            observer.onNext(100)
            observer.onNext(200)
            observer.onNext(300)
            observer.onCompleted()
            return Disposables.create()
        }
        let customDisposable = customObservable.subscribe(onNext: { (item) in
            print("Custom Observable --> \(item)")
        })
        customDisposable.dispose()
        
        
        // deferred -- 直到订阅发生时才创建，可以为每个订阅者都创建特定Observable
        let deferredObservable = Observable<String>.deferred { () -> Observable<String> in
            print("Deferred Observable --- 调用内部创建")
            return Observable.just("Hello Deferred Observable")
        }
        deferredObservable.subscribe(onNext: { (item) in
            print(item)
        }).disposed(by: disposeBag)
        
        // interval -- 每隔一段时间就产生一个元素
        
        // empty -- 创建一个空序列 只有onCompleted事件  这个Observable使用场景是啥
        // never -- 创建一个不会返回事件的Observable 同样使用场景是什么？
        
        // of 可以创建一个可变数量元素的Observable
        
        let subject1 = PublishSubject<String>()
        let subject2 = PublishSubject<String>()
        
        Observable.merge([subject1, subject2]).subscribe(onNext: { (item) in
            print("Merge---> \(item)")
        }).disposed(by: disposeBag)
        
        subject1.onNext("Github")
        subject2.onNext("Swift")
        subject1.onNext("juejin")
        subject2.onNext("javascript")
        
        
        
    }
    
    

}

/*
 filter
 map
 zip
 
 
 
 
 */
