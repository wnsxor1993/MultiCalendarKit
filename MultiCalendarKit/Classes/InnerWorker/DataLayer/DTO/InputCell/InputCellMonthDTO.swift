//
//  InputCellDTO.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/01/04.
//

import Foundation

public struct InputCellMonthDTO: Hashable {
    
    public let year: String
    public let month: String
    public let days: [InputCellDayDTO]
}
