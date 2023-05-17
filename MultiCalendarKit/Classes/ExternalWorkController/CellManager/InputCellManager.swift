//
//  InputCellManager.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/01/10.
//

import RxSwift
import RxRelay

@available(iOS 13, *)
public class InputCellManager {
    
    private var inputTexts: [String: [String]]
    // MARK: 이전 입력값들로 초기 구현되었는지 확인 (달력 + 입력 값)
    private(set) var isUpdated: Bool = false
    
    /**
        날짜 별 InputTexts를 관리하는 Relay 프로퍼티
     
        - Description:
            - 외부에서는 직접 사용이 불가하며 CFController에서 subscribe하여 사용 (외부는 함수를 호출하여 값을 갱신해줄 수 있음)
     */
    let inputTextsRelay: PublishRelay<[String: [String]]> = .init()
    /**
        선택된 날짜의 Date 타입을 관리하는 Relay 프로퍼티
     
        - Description:
            - CFController에서 emit하며 외부에서 subscribe하여 사용
     */
    public let tappedCellDTORelay: PublishRelay<String> = .init()
    
    /**
        InputCellManager 객체 생성 이니셜라이저
     
        - parameters:
            - inputTexts: Date 별 inputTexts 설정 위한 파라미터. 생성 전에 데이터가 없을 수 있으므로 기본 값은 빈 값으로 설정
     
        - Description:
            - 이전 입력 값으로 초기 구현되면 isUpdated 값 true로 변경
     */
    public init(inputTexts: [String : [String]] = [:]) {
        self.inputTexts = inputTexts
        
        if !(inputTexts.isEmpty) {
            self.isUpdated = true
            self.inputTextsRelay.accept(inputTexts)
        }
    }
    
    /**
        이니셜라이징 당시에 inputTexts 설정이 불가했을 경우, 직접 할당하기 위한 함수
     
        - parameters:
            - with: Date 별 inputTexts 설정 위한 파라미터.
     */
    public func setInputTexts(with inputTexts: [String: [String]]) {
        self.isUpdated = true
        self.inputTexts = inputTexts
        self.inputTextsRelay.accept(inputTexts)
    }
    
    /**
        새로 추가한 입력 값을 업데이트하기 위한 함수
     
        - parameters:
            - to: 새로운 입력 값이 들어갈 날짜
            - with: 새로운 입력 값
     */
    public func updateInputText(to date: String, with text: String) {
        if var textArray = self.inputTexts[date] {
            textArray.append(text)
            self.inputTexts[date] = textArray
            self.inputTextsRelay.accept(inputTexts)
            
        } else {
            self.inputTexts[date] = [text]
            self.inputTextsRelay.accept(inputTexts)
        }
    }
    
    /**
        탭한 CellDay의 날짜 타입을 전달
     
        - parameters:
            - which: 탭한 날짜의 DayDTO
     */
    func sendTappedCell(which dayDTO: InputCellDayDTO) {
        self.tappedCellDTORelay.accept(dayDTO.date)
    }
}
