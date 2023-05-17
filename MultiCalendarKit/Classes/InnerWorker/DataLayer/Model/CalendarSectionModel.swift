//
//  SectionModel.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/01/04.
//

import RxDataSources

public struct CalendarSectionModel {
    
    public var header: String
    public var items: [CellModel]
}

extension CalendarSectionModel: SectionModelType, Hashable {
    
    public typealias Item = CellModel
    public typealias Identity = String
    
    public var identity: String {
        
        return header
    }
    
    public init(original: CalendarSectionModel, items: [CellModel]) {
        self = original
        self.items = items
    }
}
