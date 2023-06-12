//
//  MultiSelectManager.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/05/11.
//

import RxSwift
import RxRelay

@available(iOS 13, *)
public class MultiSelectCellManager {
    
    public enum SelectOption {
        case multi
        case single
    }
    
    private(set) var startMonthIndex: Int?
    private(set) var endMonthIndex: Int?
    private(set) var startDayIndex: (Int, Int)?
    private(set) var endDayIndex: (Int, Int)?
    
    private var startDay: SelectCellDayDTO?
    private var endDay: SelectCellDayDTO?
    
    /**
        선택된 Start 날짜의 Date 타입을 관리하는 Relay 프로퍼티
     
        - Description:
            - CFController에서 emit하며 외부에서 subscribe하여 사용
     */
    public let tappedStartDateRelay: PublishRelay<String> = .init()
    
    /**
        선택된 End 날짜의 Date 타입을 관리하는 Relay 프로퍼티
     
        - Description:
            - CFController에서 emit하며 외부에서 subscribe하여 사용
     */
    public let tappedEndDateRelay: PublishRelay<String> = .init()
    
    /**
        날짜가 선택되었다는 것을 CFController에 알려주는 Relay 프로퍼티
     
        - Description:
            - CFController에서 subscribe하여 사용
     */
    let tappedCellDTORelay: PublishRelay<SelectCellDayDTO> = .init()
    
    private var selectOption: SelectOption = .multi
    
    /**
        MultiSelectManager 객체 생성 이니셜라이저
     */
    public init() { }
    
    /**
        멀티 캘린더의 옵션 설정
     
        - parameters:
            - with: 기본인 Multi로도 가능하고, Single 옵션도 설정 가능
     */
    public func setSelectOption(with option: SelectOption) {
        self.selectOption = option
    }
    
    /**
        탭한 CellDay의 날짜 타입을 전달
     
        - parameters:
            - which: 탭한 날짜의 DayDTO
     */
    func sendTappedCell(which dayDTO: SelectCellDayDTO, dayIndex: (Int, Int), monthIndex: Int) {
        self.checkWhatSortSelected(with: dayDTO, dayIndex: dayIndex, monthIndex: monthIndex)
        self.tappedCellDTORelay.accept(dayDTO)
    }
}

private extension MultiSelectCellManager {
    
    func checkWhatSortSelected(with dayDTO: SelectCellDayDTO , dayIndex: (Int, Int), monthIndex: Int) {
        guard self.selectOption == .multi else {
            self.configureBasicDate(with: dayDTO, dayIndex: dayIndex, monthIndex: monthIndex)
            
            return
        }
        
        guard let startDay, endDay != nil else {
            self.configureBasicDate(with: dayDTO, dayIndex: dayIndex, monthIndex: monthIndex)
            
            return
        }
        
        print("StartDay is already")
        
        guard let endDay else {
            self.configureEndDate(with: dayDTO, dayIndex: dayIndex, monthIndex: monthIndex)
            
            return
        }
        
        print("EndDay is already")
        print("Start: \(startDay.date)\nEnd: \(endDay.date)\nDayDTO: \(dayDTO.date)")
        
        guard startDay.date == dayDTO.date, endDay.date == dayDTO.date else {
            startDay.date > dayDTO.date ? self.configureStartDate(with: dayDTO, dayIndex: dayIndex, monthIndex: monthIndex) : self.configureEndDate(with: dayDTO, dayIndex: dayIndex, monthIndex: monthIndex)
            
            return
        }
        
        guard let startDayNum = Int(startDay.dayString), let endDayNum = Int(endDay.dayString), let dayDTONum = Int(dayDTO.dayString) else { return }
        
        if startDayNum > dayDTONum || (startDayNum < dayDTONum && endDayNum > dayDTONum) {
            self.configureStartDate(with: dayDTO, dayIndex: dayIndex, monthIndex: monthIndex)
            
            return
        }
        
        if endDayNum < dayDTONum {
            self.configureEndDate(with: dayDTO, dayIndex: dayIndex, monthIndex: monthIndex)
            
            return
        }
    }
    
    func configureBasicDate(with dayDTO: SelectCellDayDTO , dayIndex: (Int, Int), monthIndex: Int) {
        self.startDay = dayDTO
        self.startDayIndex = dayIndex
        self.startMonthIndex = monthIndex
        
        self.endDay = dayDTO
        self.endDayIndex = dayIndex
        self.endMonthIndex = monthIndex
        
        self.tappedStartDateRelay.accept(dayDTO.dateString)
        self.tappedEndDateRelay.accept(dayDTO.dateString)
    }
    
    func configureStartDate(with dayDTO: SelectCellDayDTO , dayIndex: (Int, Int), monthIndex: Int) {
        self.startDay = dayDTO
        self.startDayIndex = dayIndex
        self.startMonthIndex = monthIndex
        
        self.tappedStartDateRelay.accept(dayDTO.dateString)
    }
    
    func configureEndDate(with dayDTO: SelectCellDayDTO , dayIndex: (Int, Int), monthIndex: Int) {
        self.endDay = dayDTO
        self.endDayIndex = dayIndex
        self.endMonthIndex = monthIndex
        
        self.tappedEndDateRelay.accept(dayDTO.dateString)
    }
}
