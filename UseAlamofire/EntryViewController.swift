//
//  EntryViewController.swift
//  UseAlamofire
//
//  Created by kede on 2018/11/2.
//  Copyright © 2018 Clare320. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa


/**
 1. 数据源发生变化后如何更新 ---> 让Obserable重新产生新数据源
 */


class EntryViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    
    lazy var items = [
        "Calculator",
        "Swift",
        "Object-C",
        "C++",
    ]
    
    let itemsObservable: PublishSubject<[String]> = PublishSubject<[String]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
    }
    

    func setupUI() {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        
        barButtonItem.rx.tap.subscribe(onNext: {[weak self] in
            guard let self = self else {
                return
            }
            self.items.append("JavaScript")
            self.itemsObservable.onNext(self.items)
        }).disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem = barButtonItem
        
        
//        let itemsObservable = PublishSubject.just(items)
        
        itemsObservable.bind(to: tableView.rx.items(cellIdentifier: "RxSwift", cellType: UITableViewCell.self)) { (row, element, cell) in
            cell.textLabel?.text = element
        }.disposed(by: disposeBag)
        
//        tableView.rx.modelSelected(String.self).subscribe(onNext: { (value) in
//            print("Click \(value)")
//        }).disposed(by: disposeBag)
//
//
//        tableView.rx.itemSelected.subscribe(onNext: {
//            print("section:\($0.section), row:\($0.row)")
//        }).disposed(by: disposeBag)
        
        itemsObservable.onNext(items)
        
        tableView.rx.modelItemSelected(String.self).subscribe(onNext: {
           
            let (item, indexPath) = $0
            self.tableView.deselectRow(at: indexPath, animated: true)
            print("rowValue:\(item), indexPath:\(indexPath)")
        }).disposed(by: disposeBag)
        
    }

}

extension UIViewController {
    
}


/*
 public func modelSelected<T>(_ modelType: T.Type) -> ControlEvent<T> {
 let source: Observable<T> = self.itemSelected.flatMap { [weak view = self.base as UITableView] indexPath -> Observable<T> in
 guard let view = view else {
 return Observable.empty()
 }
 
 return Observable.just(try view.rx.model(at: indexPath))
 }
 
 return ControlEvent(events: source)
 }

 */

extension Reactive where Base: UITableView {
    
   // ControlEvent 是遵守ControlEventType协议的结构体， ControlEventType 继承于ObservableType
    
    public func modelItemSelected<T>(_ modelType: T.Type) -> ControlEvent<(item: T, indexPath: IndexPath)> {
        let source: Observable<(item: T, indexPath: IndexPath)> = self.itemSelected.flatMap { [weak view = self.base as UITableView] indexPath -> Observable<(item: T, indexPath: IndexPath)> in
            guard let view = view else {
                return Observable.empty()
            }
            return Observable.just((item: try view.rx.model(at: indexPath), indexPath: indexPath))
        }
        return ControlEvent(events: source)
    }
}
