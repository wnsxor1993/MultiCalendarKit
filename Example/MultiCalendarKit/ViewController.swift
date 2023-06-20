//
//  ViewController.swift
//  MultiCalendarKit
//
//  Created by wnsxor1993 on 05/17/2023.
//  Copyright (c) 2023 wnsxor1993. All rights reserved.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import MultiCalendarKit

class ViewController: UIViewController {
    
    private let resetButton: UIButton = .init().then {
        $0.setTitle("리셋", for: .normal)
        $0.titleLabel?.textColor = .white
        $0.backgroundColor = .blue
    }
    
    private let disposeBag: DisposeBag = .init()
    private let cellManager: MultiSelectCellManager = .init()
    private lazy var cfController: CFController = .init(with: .multiSelectType(self.cellManager), viewWillAppear: self.rx.viewWillAppear.asDriver(onErrorJustReturn: false), viewWillDisappear: self.rx.viewWillDisappear.asDriver(onErrorJustReturn: false))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.configureLayouts()
        self.bindWithCellManager()
        self.cellManager.setSelectOption(with: .multi)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

private extension ViewController {
    
    func configureLayouts() {
        self.view.addSubview(cfController.calendarView)
        self.view.addSubview(resetButton)
        
        cfController.calendarView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalToSuperview().inset(80)
        }
        
        resetButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(15)
        }
    }
    
    func bindWithCellManager() {
        self.cellManager.tappedStartDateRelay
            .subscribe { result in
                guard let date = result.element else { return }
                
                print("Start: \(date)")
            }
            .disposed(by: disposeBag)
        
        self.cellManager.tappedEndDateRelay
            .subscribe { result in
                guard let date = result.element else { return }
                
                print("End: \(date)")
            }
            .disposed(by: disposeBag)
        
        self.resetButton.rx.tap
            .asDriver()
            .drive(with: self) { (owner, _) in
                owner.cfController.resetAll()
            }
            .disposed(by: disposeBag)
    }
}

