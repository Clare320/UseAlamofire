//
//  ConceptViewController.swift
//  UseAlamofire
//
//  Created by kede on 2018/10/30.
//  Copyright © 2018 Clare320. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift
import Alamofire

class ConceptViewController: UIViewController {

    var disposeBag = DisposeBag()
    
    let variableArray: Variable<[String]?> = Variable(nil)
    
    var requestObservable: Observable<Any>?
    
    var students: [String]? {
        didSet {
            print("students new value is: \(students as Any)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        testObservable()
        
//        let _ = getRepo("ReactiveX/RxSwift").do(onSuccess: { (data) in
//             print("Sigle--->\(data)")
//        }, onError: { (error) in
//            print("Sigle--->\(error)")
//        }) {
//            print("----> disponsed")
//        }
        let _ = getRepo("ReactiveX/RxSwift").subscribe(onSuccess: { (data) in
            print("Sigle-->\(data)")
        }) { (error) in
            print("Sigle-->\(error)")
        }.disposed(by: disposeBag)
    
        testAsyncSubject()
    }
    
    func testObservable() -> Void {
        // 创建
        let numbers: Observable<Int> = Observable.create { (observer) -> Disposable in
            
            for i in 0...9 {
                observer.onNext(i)
            }
            observer.onCompleted()
            return Disposables.create()
        }
        
        let disposable1 = numbers.subscribe { (e) in
            print(e.element ?? "no value")
        }
        
        disposable1.dispose()
       
        print("---End---")
        
    }
    
    @IBAction func createNewRequest(_ sender: Any) {
        // 封装一个网络请求 ---
        // 问题 再次请求时是重新创建还是怎么可以再次触发
        
         requestObservable = Observable.create { (observer) -> Disposable in
            let url = "Account/GetFavoriteList?pageSize=10&pageIndex=1"
            NetManager.default.header["salePlatformId"] = "60CBE5FE-71A7-4660-9BEC-1422227D6ADB"
            NetManager.default.header["token"] = "dce16d2d0e374585982abfd3038c65e7"
            let task = NetManager.default.request(url, method: .post).responseJSON { (response) in
                if response.result.isSuccess {
                    guard let json = response.result.value else {
                        print("response is null value")
                        observer.onError(MyError(msg: "response is null value"))
                        return
                    }
                    
                    observer.onNext(json)
                    observer.onCompleted()
                    
                } else {
                    print(response.result.error!.localizedDescription)
                    observer.onError(response.result.error!)
                    guard let error = response.error as? AFError else {
                        return
                    }
                    print("AFError: \(error)")
                    
                    // -- 获取http状态码 --
                    print("HTTPStatusCode: \(String(describing: response.response?.statusCode))")
                    
                }
            }
            return Disposables.create { task.cancel() }
        }
    }
    
    @IBAction func invokeRequest(_ sender: Any) {
        requestObservable!.subscribe(onNext: { (json) in
            print("获取到的数据:\(json)")
        }, onError: { (error) in
            print("Error: \(error)")
        }, onCompleted: {
            print("请求完成")
        }).disposed(by: disposeBag)
    }
    
    // 创建single
    /*
     1. 状态不会共享
     2. 要么发出一个元素 要么发出错误事件
     */
    func getRepo(_ repo: String) -> Single<Any> {
        return Single<Any>.create {single in
            let task = Alamofire.request("https://api.github.com/repos/\(repo)").responseJSON(completionHandler: { (response) in
                if response.result.isSuccess {
                    single(.success(response.result.value ?? "no value"))
                } else {
                    single(.error(response.result.error!))
                }
            })
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    // Completable
    /*
     1. 不发出元素
     2. 要么发出一个completed事件或error事件
     3. 不会共享状态变化
     
     用来做数据处理，存储
     */
    
    // Maybe
    /*
     1. 要么发出一个元素 或 completed事件或error事件
     2. 不会共享状态变化
     */
    
    // Driver
    /*
     1. 不产生错误事件
     2. 一定在MainScheduler监听
     3. 共享状态变化
     */
    
    // ControlEvent -- 专门用于描述UI控件所产生的事件
    
    // 测试AsyncSubject -- 在序列完成事件后只发最后一个元素，没有元素时只有完成事件
    // PublishSubject -- 对订阅者发送订阅后产生的元素
    // ReplaySubject -- 不管何时订阅都将对观察者发送全部的元素
    // BehaviorSubject -- 观察者订阅时会将最新的元素发出来（不存在就发默认的），然后将产生的元素发出来
    // Variable -- 将Swift中变量Rx化 --- 下个版本就废弃了，再说还没有didSet用着方便
    // controlProperty -- 专门描述UI控件属性的
    
    func testAsyncSubject() {
        let subject = AsyncSubject<String>()
        
        let _ = subject.subscribe {
            print("Subscription: 1 Event: \($0)")
        }
        
        subject.onNext("🐶")
        subject.onNext("🐷")
        subject.onNext("🐱")
        
        subject.onCompleted()
    }
    
    func testVariable() -> Void {
        variableArray.asObservable()
            .subscribe(onNext: { (newValue) in
                print(newValue as Any)
            }).disposed(by: disposeBag)
        
        variableArray.value = ["1", "2", "3"]
        
        students = ["Mark", "Jhon", "Clare"]
    }
    
}

struct MyError: Error {
    var message: String
    
    init(msg:String) {
        message = msg
    }
}

/*
 Observable ---> 可被观察的序列
 Observer 观察者 ---> 响应Observable发出的事件
 Operator
 Disposable -- 可被清除的资源  三种清除方式 1. 手动dispose() 2. 使用DisposeBag 3. 使用takeUntil()
 Schedulers -- 调度器 Rx多线程处理模块
 Error Handling -- 错误处理
 */
