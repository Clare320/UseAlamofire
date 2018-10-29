//
//  SecondViewController.swift
//  UseAlamofire
//
//  Created by kede on 2018/10/26.
//  Copyright © 2018 Clare320. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

class SecondViewController: UIViewController {

    @IBOutlet weak var primeTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    
    var result: String?
    
    
    var tfSubscription: Disposable?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        testReactiveValues()
        testUIBinding()
        
    }

    func testReactiveValues() -> Void {
        let a = BehaviorRelay(value: 1)
        let b = BehaviorRelay(value: 2)
        
        let c = Observable.combineLatest(a, b) { $0 + $1 }
            .filter { $0 >= 0 }
            .map { "\($0) is positive" }
        
        let _ = c.subscribe(onNext: { print($0) })
        
        a.accept(4)
        b.accept(-8)
//        b.value = -8
    }
    
    func testUIBinding() -> Void {
//        tfSubscription = primeTextField.rx.text
//            .bind(to: resultLabel.rx.text)
        
        tfSubscription = primeTextField.rx.text.subscribe(onNext: {value in
            print(value ?? "no value")
        })
        
        primeTextField.text = "43"
        primeTextField.sendActions(for: .editingDidEnd)
    }

    
    deinit {
        tfSubscription?.dispose()
    }
}
