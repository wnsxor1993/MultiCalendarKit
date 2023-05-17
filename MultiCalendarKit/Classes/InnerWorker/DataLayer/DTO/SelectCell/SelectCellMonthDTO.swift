//
//  SelectCellMonthDTO.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/05/11.
//

import Foundation

public struct SelectCellMonthDTO: Hashable {
    
    public let year: String
    public let month: String
    public let days: [SelectCellDayDTO]
}
