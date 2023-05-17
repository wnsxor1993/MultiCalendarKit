//
//  CalendarInputCell.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/01/03.
//

import UIKit
import Then
import SnapKit

final class CalendarInputCell: UICollectionViewCell {
    
    static let identifier = "CalendarInputCell"
    
    private let verticalStackView: UIStackView = .init().then {
        $0.distribution = .fillEqually
        $0.axis = .vertical
        $0.alignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configureLayouts()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("This initializer does not use")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.verticalStackView.arrangedSubviews.forEach {
            self.verticalStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    /**
        생성된 DayView 인스턴스들을 기반으로 주별 날짜 생성 위해 호출
     
        - parameters:
            - dayViews: 생성된 DayView 인스턴스 배열
     */
    func setWeekDays(with dayViews: [InputCellDayView]) {
        let weekDays: [[InputCellDayView]] = dayViews.split(to: 7)
        var weekNumber: Int = 0
        
        weekDays.forEach {
            $0.forEach { dayView in
                dayView.setWeekLine(with: weekNumber)
            }
            
            self.configureWeekDays(with: $0)
            weekNumber += 1
        }
    }
}

private extension CalendarInputCell {
    
    func configureLayouts() {
        self.addSubview(verticalStackView)
        
        self.verticalStackView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configureWeekDays(with dayView: [InputCellDayView]) {
        let weekStackView: UIStackView = .init().then {
            $0.distribution = .fillEqually
            $0.axis = .horizontal
            $0.alignment = .center
        }
        
        weekStackView.addArrangedSubviews(dayView)
        
        dayView.forEach {
            $0.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
            }
        }
        
        self.verticalStackView.addArrangedSubview(weekStackView)
        
        weekStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
    }
}
