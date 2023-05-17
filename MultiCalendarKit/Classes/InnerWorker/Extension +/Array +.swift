//
//  Array +.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/01/06.
//

import Foundation

extension Array {
    
    // 잘못된 배열 index 접근으로 인한 fatalError 방지
    subscript (safe index: Int) -> Element? {
        
        return indices.contains(index) ? self[index] : nil
    }
    
    // 배열을 원하는 숫자만큼 쪼개기
    func split(to divideNumber: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: divideNumber).map {
            Array(self[$0 ..< Swift.min($0 + divideNumber, count)])
        }
    }
}
