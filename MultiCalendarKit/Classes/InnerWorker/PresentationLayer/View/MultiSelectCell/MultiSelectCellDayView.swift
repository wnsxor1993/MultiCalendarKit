//
//  MultiSelectCellDayView.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/05/11.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxGesture

/**
    날짜 하나하나를 담당하는 View
 */
final class MultiSelectCellDayView: UIView {
    
    private let dayLabel: UILabel = .init().then {
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 14)
        $0.sizeToFit()
    }
    
    private let onlySelectedView: UIView = .init().then {
        $0.backgroundColor = .init(red: 25/255, green: 132/255, blue: 255/255, alpha: 1)
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    
    private let centerConnectedView: UIView = .init().then {
        $0.backgroundColor = .init(red: 25/255, green: 132/255, blue: 255/255, alpha: 1)
        $0.isHidden = true
    }
    
    private let startConnectedView: UIView = .init().then {
        $0.backgroundColor = .init(red: 25/255, green: 132/255, blue: 255/255, alpha: 1)
        $0.isHidden = true
    }
    
    private let endConnectedView: UIView = .init().then {
        $0.backgroundColor = .init(red: 25/255, green: 132/255, blue: 255/255, alpha: 1)
        $0.isHidden = true
    }
    
    private(set) var isEmpty: Bool = false
    
    private(set) var dayLine: Int = 0
    private(set) var weekLine: Int = 0
    
    init() {
        super.init(frame: .zero)
        
        self.configureLayouts()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("This initializer does not use")
    }
    
    /**
        DayView의 필요 프로퍼티 값을 할당하기 위해 호출
     
        - parameters:
            - day: 해당 날짜의 Stirng 타입
            - inputTexts: 해당 날짜에 입력된 내용들
            - dayLine: 해당 날짜의 요일 index 값
     */
    func setProperties(with day: String, dayLine: Int) {
        self.dayLabel.text = day
        self.dayLine = (dayLine % 7)
        self.configureDayLabelColor()
        self.configureCornerRadius()
        
        if day == "" {
            self.isEmpty = true
        }
    }
    
    func setWeekLine(with lineNumber: Int) {
        self.weekLine = lineNumber
    }
    
    /**
        해당 날짜의 요일, 주 관련 인덱스 값이 필요할 경우 호출
     
        - returns:
            요일과 주의 인덱스 값을 튜플 타입으로 리턴
     */
    func fetchDayWeekLine() -> (Int, Int) {
        return (dayLine, weekLine)
    }
    
    /**
        해당 날짜 뷰의 터치 이벤트를 연결하기 위해 호출
     
        - returns:
            해당 인스턴스 값을 리턴
     */
    func fetchViewTouchGesture() -> Driver<MultiSelectCellDayView?> {
        return self.rx.tapGesture()
            .when(.recognized)
            .map { _ in
                self
            }.asDriver(onErrorJustReturn: nil)
    }
}

// MARK: Cell 선택 관련 함수
extension MultiSelectCellDayView {
    
    func selectOnly() {
        self.onlySelectedView.isHidden = false
        
        self.changeSelectedDayLabelColor()
    }
    
    func selectToStart() {
        self.onlySelectedView.isHidden = false
        self.startConnectedView.isHidden = false
        
        self.changeSelectedDayLabelColor()
    }
    
    func selectToEnd() {
        self.onlySelectedView.isHidden = false
        self.endConnectedView.isHidden = false
        
        self.changeSelectedDayLabelColor()
    }
    
    func selectToConnect() {
        self.centerConnectedView.isHidden = false
        
        self.changeSelectedDayLabelColor()
    }
    
    func resetSelected() {
        self.onlySelectedView.isHidden = true
        self.startConnectedView.isHidden = true
        self.endConnectedView.isHidden = true
        self.centerConnectedView.isHidden = true
        
        self.changeDefaultDayLabelColor()
    }
}

private extension MultiSelectCellDayView {
    
    func configureLayouts() {
        self.addSubviews(onlySelectedView, startConnectedView, endConnectedView, centerConnectedView, dayLabel)
        
        self.dayLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        self.onlySelectedView.snp.makeConstraints {
            $0.center.equalTo(self.dayLabel.snp.center)
            $0.height.equalTo(self.dayLabel.snp.height).multipliedBy(1.8)
            $0.width.equalToSuperview()
        }
        
        self.startConnectedView.snp.makeConstraints {
            $0.centerY.equalTo(self.dayLabel.snp.centerY)
            $0.leading.equalTo(self.onlySelectedView.snp.centerX)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(self.dayLabel.snp.height).multipliedBy(1.8)
        }
        
        self.endConnectedView.snp.makeConstraints {
            $0.centerY.equalTo(self.dayLabel.snp.centerY)
            $0.trailing.equalTo(self.onlySelectedView.snp.centerX)
            $0.leading.equalToSuperview()
            $0.height.equalTo(self.dayLabel.snp.height).multipliedBy(1.8)
        }
        
        self.centerConnectedView.snp.makeConstraints {
            $0.centerY.equalTo(self.dayLabel.snp.centerY)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(self.dayLabel.snp.height).multipliedBy(1.8)
        }
    }
    
    func configureDayLabelColor() {
        if dayLine == 0 {
            self.dayLabel.textColor = .red
            
        } else if dayLine == 6 {
            self.dayLabel.textColor = .blue
        }
    }
    
    func configureCornerRadius() {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        self.onlySelectedView.layer.cornerRadius = self.onlySelectedView.frame.height / 2
    }
}

private extension MultiSelectCellDayView {
    
    func changeSelectedDayLabelColor() {
        self.dayLabel.textColor = .white
    }
    
    func changeDefaultDayLabelColor() {
        guard dayLine == 0 || dayLine == 6 else {
            self.dayLabel.textColor = .black
            return
        }
        
        self.configureDayLabelColor()
    }
}
