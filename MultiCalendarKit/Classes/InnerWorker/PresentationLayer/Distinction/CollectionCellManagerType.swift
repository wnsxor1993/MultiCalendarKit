//
//  CollectionCellType.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/01/04.
//

import Foundation

/**
    달력의 Cell 타입을 지정하기 위한 Enum
 */
public enum CollectionCellManagerType {
    
    /**
        가계부같이 달력에 입력이 가능한 형태의 Cell
     */
    case inputType(InputCellManager)
    /**
        연속적인 날짜를 선택할 수 있는 형태의 Cell
     */
    case multiSelectType(MultiSelectCellManager)
}

extension CollectionCellManagerType {
    
    /**
        해당 Enum의 구체 타입을 AnyObject로 반환
     */
    var managerClass: AnyObject {
        switch self {
        case .inputType(let inputCellManager):
            return inputCellManager
            
        case .multiSelectType(let multiCellManager):
            return multiCellManager
        }
    }
}
