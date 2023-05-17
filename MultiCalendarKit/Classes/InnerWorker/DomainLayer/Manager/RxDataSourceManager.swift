//
//  RxDataSourceManager.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/01/04.
//

import RxSwift
import RxDataSources

/**
    RxDataSource의 관리 객체
 */
final class RxDataSourceManager {
    
    // Cell 타입 구분
    enum DataSourceSection {
        case input([String: [String]]?)
        case multiSelect
    }
    
    private let calendarService: CalendarService
    
    private var calendarSection: CalendarSectionModel?
    
    /**
     RxDataSource 매니저 객체 생성 이니셜라이저
     
     - parameters:
     - beforeYear: 현재 년도로부터 몇 년 앞까지 설정 (미입력 시 1로 고정)
     - afterYear: 현재 년도로부터 몇 년 뒤까지 설정 (미입력 시 1로 고정)
     */
    init(yearInterval: Int) {
        self.calendarService = .init(yearInterval: yearInterval)
    }
    
    /**
        설정한 Cell 타입의 CalendarSectionModel 값을 가져오기 위해 호출
        - parameters:
            - with section:  CalendarSectionModel 생성 시, 어떤 Cell 타입으로 추출할 지 선택할 수 있도록 Section enum을 파라미터로 받음.
     
        - returns:
            - 생성 혹은 갱신된 CalendarSectionModel
     */
    func fetchCalendarSectionModel(with section: DataSourceSection) -> CalendarSectionModel {
        switch section {
        case .input(_):
            return self.fetchInputCellSectionModel(with: section)
            
        case .multiSelect:
            return self.fetchMultiSelectCellSectionModel(with: section)
        }
    }
    
    /**
        이번 년도의 당월의 Cell row Index 값을 가져오기 위해 호출
     
        - returns:
            - 이번 년도의 당월의 Cell row Index 값에 대한 옵셔널 Int 타입
     */
    func fetchNowDayRow() -> Int? {
        guard let calendarSection else { return nil }
        
        let nowYear: String = self.calendarService.convertYearToString(format: "yyyy")
        let nowMonth: String = self.calendarService.convertMonthToString(format: "MM")
        
        let nowCellItem: CellModel? = calendarSection.items.filter { cellItem in
            switch cellItem {
            case let .inputCell(cellDTO):
               return cellDTO.year == nowYear && cellDTO.month == nowMonth
                
            case let .multipleSelectCell(cellDTO):
                return cellDTO.year == nowYear && cellDTO.month == nowMonth
            }
        }.first
        
        if let nowCellItem {
            let row: Int? = calendarSection.items.firstIndex(of: nowCellItem)
            
            return row
        }
        
        return nil
    }
}

// MARK: SectionModel Fetch
private extension RxDataSourceManager {
    
    // InputCell 타입의 CalendarSectionModel 값을 가져오기 위해 호출
    func fetchInputCellSectionModel(with section: DataSourceSection) -> CalendarSectionModel {
        // 초기 미생성 시에는 생성해서 리턴하고 이외에는 갱신받은 값을 전달
        let items: [CellModel] = self.configureSection(with: section)
        
        if let calendarSection {
            let section: CalendarSectionModel = .init(original: calendarSection, items: items)
            
            self.calendarSection = section
            
            return section
            
        } else {
            let section: CalendarSectionModel = .init(header: "InputCellModel", items: items)
            self.calendarSection = section
            
            return section
        }
    }
    
    // SelectCell 타입의 CalendarSectionModel 값을 가져오기 위해 호출
    func fetchMultiSelectCellSectionModel(with section: DataSourceSection) -> CalendarSectionModel {
        // 초기 미생성 시에는 생성해서 리턴하고 이외에는 갱신받은 값을 전달
        let items: [CellModel] = self.configureSection(with: section)
        
        if let calendarSection {
            let section: CalendarSectionModel = .init(original: calendarSection, items: items)
            
            self.calendarSection = section
            
            return section
            
        } else {
            let section: CalendarSectionModel = .init(header: "MultiSelectCellModel", items: items)
            self.calendarSection = section
            
            return section
        }
    }
}

// CellModel configure
private extension RxDataSourceManager {
    
    // section을 통해 cell의 아이템 생성을 분기 처리
    func configureSection(with section: DataSourceSection) -> [CellModel] {
        let allMonths: [Date] = self.calendarService.allYears.compactMap {
            return self.calendarService.allYearMonths[$0]
        }.flatMap { $0 }
        
        let cellModels: [CellModel] = allMonths.map {
            switch section {
            case .input(let inputTexts):
                guard let inputTexts else {
                    return self.configureInputItems(with: $0)
                }
                
                return self.configureInputItems(with: $0, inputTexts: inputTexts)
                
            case .multiSelect:
                return self.configureMultiSelectItems(with: $0)
            }
        }
        
        return cellModels
    }
    
    // InputCell Item
    func configureInputItems(with date: Date, inputTexts: [String: [String]] = [:]) -> CellModel {
        let year: String = self.calendarService.convertYearToString(with: date, format: "yyyy년")
        let month: String = self.calendarService.convertMonthToString(with: date, format: "MM월")
        let allDays: [String] = self.calendarService.allMonthDays[date] ?? []
        
        let dayDTOs: [InputCellDayDTO] = allDays.map {
            let date = "\(year)\(month)\($0)"
            
            guard let texts = inputTexts[date] else {
                return .init(date: date, dayString: $0, inputTexts: [])
            }
            
            return .init(date: date, dayString: $0, inputTexts: texts)
        }
        
        return .inputCell(.init(year: year, month: month, days: dayDTOs))
    }
    
    // MultiSelect Cell Item
    func configureMultiSelectItems(with date: Date) -> CellModel {
        let year: String = self.calendarService.convertYearToString(with: date, format: "yyyy")
        let month: String = self.calendarService.convertMonthToString(with: date, format: "MM")
        let allDays: [String] = self.calendarService.allMonthDays[date] ?? []
        
        let dayDTOs: [SelectCellDayDTO] = allDays.map {
            let dateString = "\(year).\(month).\($0)"
            
            return .init(date: date, dateString: dateString, dayString: $0)
        }
        
        return .multipleSelectCell(.init(year: year, month: month, days: dayDTOs))
    }
}
