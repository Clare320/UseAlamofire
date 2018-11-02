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
        testTransformElementOperator()
    }
    
    func testTransformElementOperator() -> Void {
        let tmpArray = [1, 2, 3, 4, 5]
        let resultArray = tmpArray.map {
            return $0 * 2
        }
        print(resultArray)
        
        // compactMap与map区别--> compactMap会过滤空值
        let flatMapArray = tmpArray.compactMap {
            return $0 * 3
        }
        print(flatMapArray)
        
        /*--转换元素--*/
        let subject = PublishSubject<Int>()
        let subject2 = PublishSubject<Int>()
        
        // map
        subject.map {
            return String(describing: $0) + "Hello"
            }.subscribe(onNext: { (item) in
                print("after map --> \(item)")
            }).disposed(by: disposeBag)
    
        // flatMap  第一次不会用 -- 咋用啊 将Observable中元素转化为
        
       
//        subject.flatMap(<#T##selector: (Int) throws -> ObservableConvertibleType##(Int) throws -> ObservableConvertibleType#>)
        
        
        let flatMapObservable = Observable.of(subject)
        
        flatMapObservable.flatMap { e in
            return Observable<String>.create({ (observer) -> Disposable in
                observer.onNext("Hello FlatMap \(e)")
                observer.onCompleted()
                
                return Disposables.create()
            })
            }.subscribe(onNext: { (element) in
                print("Flatmap ---> \(element)")
            }).disposed(by: disposeBag)
        
        
        subject.onNext(999)
        subject.onNext(666)
        subject.onNext(333)
        
        flatMapObservable.subscribe(onNext: { (e) in
            print("flatMapObservable-->\(e)")
        }).disposed(by: disposeBag)
    
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
        
        
        /*----通过组合其它的Observable来创建Observable*/
        
        let subject1 = PublishSubject<String>()
        let subject2 = PublishSubject<String>()
        
        // merge 将多个observable合并
        Observable.merge([subject1, subject2]).subscribe(onNext: { (item) in
            print("Merge---> \(item)")
        }).disposed(by: disposeBag)
        
        // contact --> 按加入顺序将Observable串联起来，前一个发送完毕后一个才可以开始发送（前一个没完成后一个即使产生也不会被发送）
        subject1.concat(subject2).subscribe {
            print($0)
        }.disposed(by: disposeBag)
        
        // zip  --- 严格按照序列索引数组合 新组合的Observable的元素数量等于源Observable中数量最少的那个。
        Observable.zip(subject1, subject2) {
                $0 + $1 + "we are zip"
            }.subscribe(onNext: {
                print("zip---> \($0)")
            }).disposed(by: disposeBag)
        
        
        // combineLatest --> 源中任何一个Observable发出元素，新的Observable都会发出一个（前提是源中Observablez曾经发出过）
        Observable.combineLatest(subject1, subject2) {
            "--CombineLatest--" + $0 + $1
            }.subscribe(onNext: {
                print("CombineLatest--->\($0)")
            }).disposed(by: disposeBag)
        
        
        // scan --> 将前一个元素按闭包处理后的结果当成后一个元素处理的参数 类似于Array中reduce
        
        
        subject1.onNext("Github")
        subject2.onNext("Swift")
        subject1.onNext("juejin")
        subject1.onCompleted()
        subject2.onNext("javascript")
        subject2.onNext("Python")
        
    }
    
    

}

/*
 filter
 map
 zip
 
 
 
 
 */
