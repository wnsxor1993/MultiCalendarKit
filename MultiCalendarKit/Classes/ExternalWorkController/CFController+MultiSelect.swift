//
//  CFController+MultiSelect.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/05/17.
//

import RxSwift
import RxCocoa
//import RxDataSources

extension CFController {
    
    // Cell 생성 메서드
    func createMultipleCell(with collectionView: UICollectionView, indexPath: IndexPath, item: CalendarSectionModel.Item) -> CalendarMultiSelectCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarMultiSelectCell.identifier, for: indexPath) as? CalendarMultiSelectCell else { return .init() }
        
        switch item {
        case .inputCell:
            break
            
        case .multipleSelectCell(let dto):
            var dayViews: [MultiSelectCellDayView] = []
            
            for (index, dayDTO) in dto.days.enumerated() {
                let dayView: MultiSelectCellDayView = self.createMultipleDayView(with: index, dayDTO: dayDTO)
                
                self.bindTouchGesture(to: dayView)
                dayViews.append(dayView)
            }

            cell.setWeekDays(with: dayViews)
        }
        
        return cell
    }
}

// MARK: Set MultiSelectedViews
extension CFController {
    
    func setSelectedViews(with multipleManager: MultiSelectCellManager, from visibleCellRow: Int? = nil) {
        guard let startMonth = multipleManager.startMonthIndex, let endMonth = multipleManager.endMonthIndex, let startDay = multipleManager.startDayIndex, let endDay = multipleManager.endDayIndex else { return }
        
        self.removeSelectedViews(from: visibleCellRow)
        self.addSelectedViews(from: visibleCellRow, startMonth: startMonth, endMonth: endMonth, startDay: startDay, endDay: endDay)
    }
    
    func removeSelectedViews(from visibleCellRow: Int?) {
        if let visibleCellRow {
            guard let monthSelectedViews = self.selectedViews[visibleCellRow], let cell = self.calendarView.calendarCollectionView.cellForItem(at: .init(row: visibleCellRow, section: 0)) as? CalendarMultiSelectCell else { return }
            
            cell.resetAllDayViews(with: monthSelectedViews)
            
        } else {
            guard let moveCellRow = self.moveCellRow, let monthSelectedViews = self.selectedViews[moveCellRow], let cell = self.calendarView.calendarCollectionView.cellForItem(at: .init(row: moveCellRow, section: 0)) as? CalendarMultiSelectCell else { return }
            
            cell.resetAllDayViews(with: monthSelectedViews)
        }
    }
    
    func addSelectedViews(from visibleCellRow: Int?, startMonth: Int, endMonth: Int, startDay: (Int, Int), endDay: (Int, Int)) {
        guard let moveCellRow = (visibleCellRow != nil) ? visibleCellRow : self.moveCellRow  else { return }
        
        // 현재 달이 시작/끝 달과 동일하고 선택 날짜가 하루일 때
        if moveCellRow == startMonth, moveCellRow == endMonth, startDay == endDay {
            guard let cell = self.calendarView.calendarCollectionView.cellForItem(at: .init(row: startMonth, section: 0)) as? CalendarMultiSelectCell, let dayView = cell.fetchStartDayView(with: startDay) else { return }
            
            cell.selectOnly(with: dayView)
            
            guard self.selectedViews[startMonth] == nil else {
                self.selectedViews[startMonth]?.append(dayView)
                return
            }
            
            self.selectedViews[startMonth] = [dayView]
            
            return
        }
        
        // 현재 달이 시작/끝 달과 동일하고 선택 날짜가 여러 날일 때
        if moveCellRow == startMonth, moveCellRow == endMonth {
            guard let cell = self.calendarView.calendarCollectionView.cellForItem(at: .init(row: startMonth, section: 0)) as? CalendarMultiSelectCell, let startView = cell.fetchStartDayView(with: startDay), let endView = cell.fetchEndDayView(with: endDay) else { return }
            
            var centerViews = cell.fetchAllDayViews(after: startView, before: endView)
            cell.selectStart(with: startView)
            cell.selectEnd(with: endView)
            cell.selectCenter(with: centerViews)
            
            centerViews.insert(startView, at: 0)
            centerViews.append(endView)
            
            guard self.selectedViews[startMonth] == nil else {
                self.selectedViews[startMonth]?.append(contentsOf: centerViews)
                return
            }
            
            self.selectedViews[startMonth] = centerViews
            
            return
        }
        
        // 현재 달이 시작 달과 동일하지만 끝 달과는 다를 때
        if moveCellRow == startMonth {
            guard let startCell = self.calendarView.calendarCollectionView.cellForItem(at: .init(row: startMonth, section: 0)) as? CalendarMultiSelectCell, let startView = startCell.fetchStartDayView(with: startDay) else { return }
            
            var afterStartViews = startCell.fetchAllDayViews(after: startView)
            startCell.selectStart(with: startView)
            startCell.selectCenter(with: afterStartViews)
            
            afterStartViews.insert(startView, at: 0)
            
            guard self.selectedViews[startMonth] == nil else {
                self.selectedViews[startMonth]?.append(contentsOf: afterStartViews)
                return
            }
            
            self.selectedViews[startMonth] = afterStartViews
            
            return
        }
        
        // 현재 달이 시작 달과 다르고 끝 달과는 동일할 때
        if moveCellRow == endMonth {
            guard let endCell = self.calendarView.calendarCollectionView.cellForItem(at: .init(row: endMonth, section: 0)) as? CalendarMultiSelectCell, let endView = endCell.fetchEndDayView(with: endDay) else { return }
            
            var beforeEndViews = endCell.fetchAllDayViews(before: endView)
            endCell.selectEnd(with: endView)
            endCell.selectCenter(with: beforeEndViews)
            
            beforeEndViews.append(endView)
            
            guard self.selectedViews[endMonth] == nil else {
                self.selectedViews[endMonth]?.append(contentsOf: beforeEndViews)
                return
            }
            
            self.selectedViews[endMonth] = beforeEndViews
            
            return
        }
        
        // 현재 달이 시작/끝 달과 다른 끼인 달일 때
        if moveCellRow > startMonth, moveCellRow < endMonth {
            guard let centerCell = self.calendarView.calendarCollectionView.cellForItem(at: .init(row: moveCellRow, section: 0)) as? CalendarMultiSelectCell else { return }
            
            let centerViews = centerCell.fetchAllDayViews()
            centerViews.forEach {
                $0.selectToConnect()
            }
            
            guard self.selectedViews[moveCellRow] == nil else {
                self.selectedViews[moveCellRow]?.append(contentsOf: centerViews)
                return
            }
            
            self.selectedViews[moveCellRow] = centerViews
        }
    }
}

// MARK: MultiCell DayView 생성 및 TapGesture 바인딩 로직
private extension CFController {
    
    func createMultipleDayView(with index: Int, dayDTO: SelectCellDayDTO) -> MultiSelectCellDayView {
        let dayView: MultiSelectCellDayView = .init()
        
        dayView.setProperties(with: dayDTO.dayString, dayLine: index)
        
        return dayView
    }
    
    func bindTouchGesture(to dayView: MultiSelectCellDayView) {
        dayView.fetchViewTouchGesture()
            .drive(with: self) { (owner, view) in
                guard let view, let moveCellRow = self.moveCellRow else { return }
                
                let index: (Int, Int) = view.fetchDayWeekLine()
                let cellArrayIndex: Int = (index.1 * 7) + index.0
                
                guard let cellModel = self.collectionViewDataSource?.sectionModels.first?.items[safe: moveCellRow] else { return }
                
                switch cellModel {
                case .inputCell:
                    break
                    
                case .multipleSelectCell(let monthDTO):
                    guard let dayDTO: SelectCellDayDTO = monthDTO.days[safe: cellArrayIndex], let multipleManager: MultiSelectCellManager = self.calendarType.managerClass as? MultiSelectCellManager else { return }
                    
                    multipleManager.sendTappedCell(which: dayDTO, dayIndex: index, monthIndex: moveCellRow)
                }
            }
            .disposed(by: self.disposeBag)
    }
}
