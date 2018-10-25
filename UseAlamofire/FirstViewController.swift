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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        testUseButton()
        testDispoding()
    }
    
    func testUseButton() -> Void {
        print123Btn.rx.tap
            .subscribe(onNext: {
            print("123>>>>")
        })
            .disposed(by:DisposeBag.init())
    }
    
    func testDispoding() {
        let scheduler = SerialDispatchQueueScheduler(qos: .default)
        let scheduler2 = MainScheduler.instance
        let subcription = Observable<Int>.interval(0.3, scheduler: scheduler)
            .subscribe{ event in
                print(event)
        }
        
        Thread.sleep(forTimeInterval: 2.0)
        
        subcription.dispose()
    }
    
}
