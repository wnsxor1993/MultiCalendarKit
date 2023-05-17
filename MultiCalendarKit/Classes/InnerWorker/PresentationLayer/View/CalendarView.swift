//
//  CalendarViewController.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/01/03.
//

import UIKit
import Then
import SnapKit

/**
    달력 전체를 담당하는 View
 */
open class CalendarView: UIView {
    
    let yearMonthLabel: UILabel = .init().then {
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.backgroundColor = .white
        $0.sizeToFit()
    }
    
    let prevButton: UIButton = .init().then {
        $0.setImage(.init(systemName: "lessthan"), for: .normal)
        $0.tintColor = .gray
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    let nextButton: UIButton = .init().then {
        $0.setImage(.init(systemName: "greaterthan"), for: .normal)
        $0.tintColor = .gray
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    private let weekStackView: UIStackView = .init().then {
        $0.alignment = .center
        $0.distribution = .fillEqually
        $0.axis = .horizontal
        $0.backgroundColor = .white
    }
    
    private let weekLineView: UIView = .init().then {
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    lazy var calendarCollectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init()).then {
        guard let layout = CollectionLayout.calendarLayout.compositionalLayoutSection else { return }
        
        $0.collectionViewLayout = layout
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .white
        
        switch self.cellType {
        case .inputType:
            $0.register(CalendarInputCell.self, forCellWithReuseIdentifier: CalendarInputCell.identifier)
            
        case .multiSelectType:
            $0.register(CalendarMultiSelectCell.self, forCellWithReuseIdentifier: CalendarMultiSelectCell.identifier)
        }
    }
    
    private let cellType: CollectionCellManagerType
    
    public init(with cellType: CollectionCellManagerType) {
        self.cellType = cellType
        
        super.init(frame: .zero)
        
        self.configureLayouts()
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("This initializer does not use")
    }
}

private extension CalendarView {
    
    func configureLayouts() {
        self.addSubviews(yearMonthLabel, prevButton, nextButton, weekStackView, weekLineView, calendarCollectionView)
        self.configureWeekLabels()
        
        self.yearMonthLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(26)
            $0.centerX.equalToSuperview()
        }
        
        self.prevButton.snp.makeConstraints {
            $0.trailing.equalTo(self.yearMonthLabel.snp.leading).offset(-30)
            $0.centerY.equalTo(self.yearMonthLabel.snp.centerY)
            $0.height.equalTo(self.yearMonthLabel.snp.height)
            $0.width.equalTo(15)
        }
        
        self.nextButton.snp.makeConstraints {
            $0.leading.equalTo(self.yearMonthLabel.snp.trailing).offset(30)
            $0.centerY.equalTo(self.yearMonthLabel.snp.centerY)
            $0.height.equalTo(self.yearMonthLabel.snp.height)
            $0.width.equalTo(15)
        }
        
        self.weekStackView.snp.makeConstraints {
            $0.top.equalTo(self.yearMonthLabel.snp.bottom).offset(45)
            $0.leading.trailing.equalToSuperview().inset(45)
            $0.height.equalTo(19)
        }
        
        self.weekLineView.snp.makeConstraints {
            $0.top.equalTo(self.weekStackView.snp.bottom).offset(9)
            $0.leading.trailing.equalToSuperview().inset(25)
            $0.height.equalTo(1)
        }
        
        self.calendarCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.weekLineView.snp.bottom).offset(55)
            $0.leading.trailing.equalToSuperview().inset(45)
            $0.bottom.equalToSuperview()
        }
    }
    
    func configureWeekLabels() {
        let weekDays: [String] = ["일", "월", "화", "수", "목", "금", "토"]
        
        weekDays.forEach { day in
            let weekLabel: UILabel = .init().then {
                $0.text = day
                $0.font = .systemFont(ofSize: 15)
                $0.textAlignment = .center
                $0.textColor = ((day == "일") ? .red : (day == "토") ? .blue : .black)
                $0.backgroundColor = .clear
            }
            
            self.weekStackView.addArrangedSubview(weekLabel)
        }
    }
}
