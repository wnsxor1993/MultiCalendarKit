//
//  DayView.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/01/06.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxGesture

/**
    날짜 하나하나를 담당하는 View
 */
final class InputCellDayView: UIView {
    
    private let dayLabel: UILabel = .init().then {
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 14)
        $0.sizeToFit()
    }
    
    private let scrollView: UIScrollView = .init().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .white
    }
    
    private let inputStackView: UIStackView = .init().then {
        $0.distribution = .fill
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 5
    }
    
    private var dayLine: Int = 0
    private var weekLine: Int = 0
    
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
    func setProperties(with day: String, inputTexts: [String], dayLine: Int) {
        self.dayLabel.text = day
        self.dayLine = (dayLine % 7)
        self.configureDayLabelColor()
        
        inputTexts.forEach {
            self.configureInputLabel(with: $0)
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
    func fetchViewTouchGesture() -> Driver<InputCellDayView?> {
        return self.rx.tapGesture()
            .when(.recognized)
            .map { _ in
                self
            }.asDriver(onErrorJustReturn: nil)
    }
}

private extension InputCellDayView {
    
    func configureLayouts() {
        self.addSubviews(dayLabel, scrollView)
        self.scrollView.addSubview(inputStackView)
        
        self.dayLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        self.scrollView.snp.makeConstraints { make in
            make.top.equalTo(dayLabel.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        self.inputStackView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    func configureInputLabel(with text: String) {
        let inputLabel: UILabel = .init().then {
            $0.font = .systemFont(ofSize: 10, weight: .regular)
            $0.textAlignment = .center
            $0.text = text
        }
        
        self.inputStackView.addArrangedSubview(inputLabel)
        
        inputLabel.snp.makeConstraints { make in
            make.height.equalTo(dayLabel.snp.height).multipliedBy(0.8)
        }
    }
    
    func configureDayLabelColor() {
        if dayLine == 0 {
            self.dayLabel.textColor = .red
            
        } else if dayLine == 6 {
            self.dayLabel.textColor = .blue
        }
    }
}
