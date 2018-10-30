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

class ConceptViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        testObservable()
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
            print(e.element!)
        }
        
        disposable1.dispose()
       
        print("---End---")
        
        // 封装一个网络请求
        
        let requestObservable: Observable<Any> = Observable.create { (observer) -> Disposable in
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
                    print(json)
                } else {
                    print(response.result.error!.localizedDescription)
                    guard let error = response.error as? AFError else {
                        return
                    }
                    print("AFError: \(error)")
                    
                    // -- 获取http状态码 --
                    print("HTTPStatusCode: \(String(describing: response.response?.statusCode))")
                }
            }
        }
        
    }
    

}

struct MyError: Error {
    var message: String
    
    init(msg:String) {
        message = msg
    }
}
