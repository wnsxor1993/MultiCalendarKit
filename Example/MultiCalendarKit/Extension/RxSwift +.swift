//
//  RxSwift +.swift
//  CalendarExample
//
//  Created by Zeto on 2023/05/10.
//

import RxSwift

extension RxSwift.Reactive where Base: UIViewController {
    
    // viewWillAppear 시, rx 호출되는 기능 (Bool 타입 방출)
    public var viewWillAppear: Observable<Bool> {
        return methodInvoked(#selector(UIViewController.viewWillAppear))
            .map { $0.first as? Bool ?? false }
    }
    
    // viewWillDisappear 시, rx 호출되는 기능 (Bool 타입 방출)
    public var viewWillDisappear: Observable<Bool> {
        return methodInvoked(#selector(UIViewController.viewWillDisappear))
            .map { $0.first as? Bool ?? false }
    }
}
