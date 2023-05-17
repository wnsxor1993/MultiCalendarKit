//
//  CellModel.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/01/04.
//

import RxDataSources

public enum CellModel: Hashable {
    
    case inputCell(InputCellMonthDTO)
    case multipleSelectCell(SelectCellMonthDTO)
}
