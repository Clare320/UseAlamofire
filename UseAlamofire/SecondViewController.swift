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

let minimalUsernameLength = 5

class SecondViewController: UIViewController {

    @IBOutlet weak var primeTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var userNameVaildLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordVaildLabel: UILabel!
    
    @IBOutlet weak var okButton: UIButton!
    
   
    
    
    var result: String?
    var tfSubscription: Disposable?
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        checkUsernameAndPassword()
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

    
    func checkUsernameAndPassword() {
        let usernameValid = userNameTextField.rx.text.orEmpty
            .map { $0.count >= minimalUsernameLength }
            .share(replay: 1)
        
        usernameValid.bind(to: passwordTextField.rx.isEnabled)
            .disposed(by: disposeBag)
        
        usernameValid.bind(to: userNameVaildLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        
        let passwordValid = passwordTextField.rx.text.orEmpty
            .map { $0.count >= minimalUsernameLength }
            .share(replay: 1)
        
        passwordValid.bind(to: passwordVaildLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        let everythingValid = Observable.combineLatest(usernameValid, passwordValid) { $0 && $1 }
            .share(replay: 1)
        everythingValid.bind(to: okButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        okButton.rx.tap.subscribe(onNext: { [weak self] in
            let alert = UIAlertController(title: "Tip", message: "This is OK!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self?.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    deinit {
        tfSubscription?.dispose()
    }
}
