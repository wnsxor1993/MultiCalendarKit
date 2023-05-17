//
//  CFController+Input.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/05/17.
//

import RxSwift
import RxCocoa
import RxDataSources

extension CFController {
    
    // Cell 생성 메서드
    func createInputCell(with collectionView: UICollectionView, indexPath: IndexPath, item: CalendarSectionModel.Item) -> CalendarInputCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarInputCell.identifier, for: indexPath) as? CalendarInputCell else { return .init() }
        
        switch item {
        case .inputCell(let dto):
            var dayViews: [InputCellDayView] = []
            
            for (index, dayDTO) in dto.days.enumerated() {
                let dayView: InputCellDayView = self.createInputDayView(with: index, dayDTO: dayDTO)
                
                self.bindTouchGesture(to: dayView)
                dayViews.append(dayView)
            }
            
            cell.setWeekDays(with: dayViews)
            
        case .multipleSelectCell:
            break
        }
        
        return cell
    }
}

// MARK: DayView 생성 및 TapGesture 바인딩 로직
private extension CFController {
    
    func createInputDayView(with index: Int, dayDTO: InputCellDayDTO) -> InputCellDayView {
        let dayView: InputCellDayView = .init()
        
        if dayDTO.inputTexts.isEmpty {
            dayView.setProperties(with: dayDTO.dayString, inputTexts: [], dayLine: index)
            
        } else {
            dayView.setProperties(with: dayDTO.dayString, inputTexts: dayDTO.inputTexts, dayLine: index)
        }
        
        return dayView
    }
    
    func bindTouchGesture(to dayView: InputCellDayView) {
        dayView.fetchViewTouchGesture()
            .drive { [weak self] view in
                guard let self, let view, let moveCellRow = self.moveCellRow else { return }
                
                let index: (Int, Int) = view.fetchDayWeekLine()
                let cellArrayIndex: Int = (index.1 * 7) + index.0
                
                guard let cellModel = self.collectionViewDataSource?.sectionModels.first?.items[safe: moveCellRow] else { return }
                
                switch cellModel {
                case .inputCell(let monthDTO):
                    guard let dayDTO: InputCellDayDTO = monthDTO.days[safe: cellArrayIndex], let inputManager: InputCellManager = self.calendarType.managerClass as? InputCellManager else { return }
                    
                    inputManager.sendTappedCell(which: dayDTO)
                    
                case .multipleSelectCell:
                    break
                }
            }
            .disposed(by: self.disposeBag)
    }
}
