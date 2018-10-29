//
//  FirstViewController.swift
//  UseAlamofire
//
//  Created by kede on 2018/10/25.
//  Copyright © 2018 Clare320. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class FirstViewController: UIViewController {

    @IBOutlet weak var print123Btn: UIButton!
    
    @IBOutlet weak var takeUntilBtn: UIButton!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        testUseButton()
//        testDispoding()
        
//        testCustomForm()
        
        testCustomInterval()
       
    }
    
    func testCustomInterval() -> Void {
//        let counter = myInterval(0.1)

//        print("Started ---- ")
//
//        let subscription = counter.subscribe(onNext: { (n) in
//            print(n)
//        })
//
//        Thread.sleep(forTimeInterval: 0.5)
//
//        subscription.dispose()
//
//        print("Ended ---- ")
        
//        let counter = myInterval(0.1).share(replay: 1)
//
//        print("Started ---- ")
//
//        let subscription = counter.subscribe(onNext: { (n) in
//            print("First: \(n)")
//        })
//
//        let subscription2 = counter.subscribe(onNext: { (n) in
//            print("Second: \(n)")
//        })
//
//        Thread.sleep(forTimeInterval: 0.5)
//
//        subscription.dispose()
//
//        Thread.sleep(forTimeInterval: 0.5)
//
//        subscription2.dispose()
//
//        print("Ended ---- ")
        
//
        
        let subscription = myInterval(0.1).myMap { (e) in
            return "This is simply \(e)"
            }.subscribe(onNext: { n in
                print(n)
            })
        
        Thread.sleep(forTimeInterval: 1)
        
        subscription.dispose()
        
        
    }
    
    
    func testCustomForm() {
        let _ = myJust(0).subscribe(onNext: { n in
            print(n)
        })
        
        
        let stringCounter = myForm(["first", "second"])
        
        print("Started ---")
        
        // -- 怎么从event中拿到element
        let _ = stringCounter.subscribe { (n) in
            print(n.element!)
        }
        
        print("---")
        
        let _ = stringCounter.subscribe { (n) in
            
            print(n.element!)
        }
        
        print("Ended ---")
    }
    
    func testUseButton() -> Void {
        print123Btn.rx.tap
            .subscribe(onNext: {
            print("123>>>>")
        })
            .disposed(by:disposeBag)
        
        let _ = takeUntilBtn.rx
            .tap
            .takeUntil(self.rx.deallocated)
            .subscribe {
                print("test takeUntil operator \($0)")
                
        }
    }
    
    func testDispoding() {
        let scheduler = SerialDispatchQueueScheduler(qos: .default)
//        let subcription = Observable<Int>.interval(0.3, scheduler: scheduler)
//            .subscribe{ event in
//                print(event)
//        }
        
        let subcription = Observable<Int>.interval(0.3, scheduler: scheduler)
            .observeOn(scheduler)
            .subscribe{ event in
                print(event)
        }
        
        Thread.sleep(forTimeInterval: 2.0)
        
        subcription.dispose()
    }
    
    func myJust<E>(_ element: E) -> Observable<E> {
        return Observable.create { observer in
            observer.on(.next(element))
            observer.on(.completed)
            return Disposables.create()
        }
    }
    
    func myForm<E>(_ sequence: [E]) -> Observable<E> {
        return Observable.create { observer in
            for element in sequence {
                observer.on(.next(element))
            }
            
            observer.on(.completed)
            return Disposables.create()
        }
    }
    
    func myInterval(_ interval: TimeInterval) -> Observable<Int> {
        return Observable.create { observer in
            print("Subscribed")
            let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            timer.schedule(deadline: DispatchTime.now(), repeating: interval)
            
            let cancel = Disposables.create {
                print("Disponsed")
                timer.cancel()
            }
            
            var next = 0
            timer.setEventHandler {
                if cancel.isDisposed {
                    return
                }
                observer.onNext(next)
                next += 1
            }
            timer.resume()
            
            return cancel
        }
    }
    
    @IBAction func createNewDisposeBag(_ sender: Any) {
        self.disposeBag = DisposeBag()
        
        let alert = UIAlertController(title: "提示", message: "一旦创建后print123将不再被订阅", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
}


extension ObservableType {
    func myMap<R>(transform: @escaping (E) -> R) -> Observable<R> {
        return Observable.create { observer in
            let subscription = self.subscribe { e in
                switch e {
                case .next(let value):
                    let result = transform(value)
                    observer.on(.next(result))
                case .error(let error):
                    observer.on(.error(error))
                case .completed:
                    observer.on(.completed)
                }
            }
            return subscription
        }
    }
}
