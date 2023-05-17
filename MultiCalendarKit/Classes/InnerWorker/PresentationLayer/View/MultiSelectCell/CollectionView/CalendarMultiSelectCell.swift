//
//  CalendarMultiSelectCell.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/05/11.
//

import UIKit
import Then
import SnapKit

final class CalendarMultiSelectCell: UICollectionViewCell {
    
    static let identifier = "CalendarMultiSelectCell"
    
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
    func setWeekDays(with dayViews: [MultiSelectCellDayView]) {
        let weekDays: [[MultiSelectCellDayView]] = dayViews.split(to: 7)
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

extension CalendarMultiSelectCell {
    
    func fetchStartDayView(with dayIndex: (Int, Int)) -> MultiSelectCellDayView? {
        guard let weekStackView = self.verticalStackView.arrangedSubviews[safe: dayIndex.1] as? UIStackView, let dayView = weekStackView.arrangedSubviews[safe: dayIndex.0] as? MultiSelectCellDayView else { return nil }
        
        return dayView
    }
    
    func fetchEndDayView(with dayIndex: (Int, Int)) -> MultiSelectCellDayView? {
        guard let weekStackView = self.verticalStackView.arrangedSubviews[safe: dayIndex.1] as? UIStackView, let dayView = weekStackView.arrangedSubviews[safe: dayIndex.0] as? MultiSelectCellDayView else { return nil }
        
        return dayView
    }
    
    func fetchAllDayViews(after startView: MultiSelectCellDayView, before endView: MultiSelectCellDayView) -> [MultiSelectCellDayView] {
        var dayViews: [MultiSelectCellDayView] = []
        
        let weekStartIndex: Int = startView.weekLine
        let dayStartIndex: Int = startView.dayLine
        
        let weekEndIndex: Int = endView.weekLine
        let dayEndIndex: Int = endView.dayLine
        
        let allDayViews: [MultiSelectCellDayView] = self.verticalStackView.arrangedSubviews.compactMap {
            return $0 as? UIStackView
        }
        .compactMap {
            return $0.arrangedSubviews
        }
        .flatMap { $0 }
        .compactMap {
            return $0 as? MultiSelectCellDayView
        }
        
        allDayViews.forEach {
            guard $0.weekLine >= weekStartIndex, $0.weekLine <= weekEndIndex else { return }
            
            if $0.weekLine == weekStartIndex, $0.weekLine == weekEndIndex, $0.dayLine > dayStartIndex, $0.dayLine < dayEndIndex {
                dayViews.append($0)
            }
            
            if $0.weekLine == weekStartIndex, $0.dayLine > dayStartIndex {
                guard $0.weekLine != weekEndIndex else { return }
                
                dayViews.append($0)
            }
            
            if $0.weekLine > weekStartIndex, $0.weekLine < weekEndIndex {
                dayViews.append($0)
            }
            
            if $0.weekLine == weekEndIndex, $0.dayLine < dayEndIndex {
                guard $0.weekLine != weekStartIndex else { return }
                
                dayViews.append($0)
            }
        }
        
        return dayViews
    }
    
    func fetchAllDayViews(after startView: MultiSelectCellDayView) -> [MultiSelectCellDayView] {
        var dayViews: [MultiSelectCellDayView] = []
        
        let weekStartIndex: Int = startView.weekLine
        let dayStartIndex: Int = startView.dayLine
        
        let allDayViews: [MultiSelectCellDayView] = self.verticalStackView.arrangedSubviews.compactMap {
            return $0 as? UIStackView
        }
        .compactMap {
            return $0.arrangedSubviews
        }
        .flatMap { $0 }
        .compactMap {
            return $0 as? MultiSelectCellDayView
        }
        
        allDayViews.forEach {
            if $0.weekLine == weekStartIndex, $0.dayLine > dayStartIndex {
                dayViews.append($0)
            }
            
            if $0.weekLine > weekStartIndex {
                dayViews.append($0)
            }
        }
        
        return dayViews
    }
    
    func fetchAllDayViews(before endView: MultiSelectCellDayView) -> [MultiSelectCellDayView] {
        var dayViews: [MultiSelectCellDayView] = []
        
        let weekStartIndex: Int = endView.weekLine
        let dayStartIndex: Int = endView.dayLine
        
        let allDayViews: [MultiSelectCellDayView] = self.verticalStackView.arrangedSubviews.compactMap {
            return $0 as? UIStackView
        }
        .compactMap {
            return $0.arrangedSubviews
        }
        .flatMap { $0 }
        .compactMap {
            return $0 as? MultiSelectCellDayView
        }
        
        allDayViews.forEach {
            if $0.weekLine == weekStartIndex, $0.dayLine < dayStartIndex {
                dayViews.append($0)
            }
            
            if $0.weekLine < weekStartIndex {
                dayViews.append($0)
            }
        }
        
        return dayViews
    }
    
    func fetchAllDayViews() -> [MultiSelectCellDayView] {
        let allDayViews: [MultiSelectCellDayView] = self.verticalStackView.arrangedSubviews.compactMap {
            return $0 as? UIStackView
        }
        .compactMap {
            return $0.arrangedSubviews
        }
        .flatMap { $0 }
        .compactMap {
            return $0 as? MultiSelectCellDayView
        }
        
        return allDayViews
    }
}

extension CalendarMultiSelectCell {
    
    func selectOnly(with dayView: MultiSelectCellDayView) {
        dayView.selectOnly()
    }
    
    func selectStart(with dayView: MultiSelectCellDayView) {
        dayView.selectToStart()
    }
    
    func selectEnd(with dayView: MultiSelectCellDayView) {
        dayView.selectToEnd()
    }
    
    func selectCenter(with dayViews: [MultiSelectCellDayView]) {
        dayViews.forEach {
            $0.selectToConnect()
        }
    }
    
    func resetAllDayViews(with dayViews: [MultiSelectCellDayView]) {
        dayViews.forEach {
            $0.resetSelected()
        }
    }
}

private extension CalendarMultiSelectCell {
    
    func configureLayouts() {
        self.addSubview(verticalStackView)
        
        self.verticalStackView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configureWeekDays(with dayView: [MultiSelectCellDayView]) {
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
