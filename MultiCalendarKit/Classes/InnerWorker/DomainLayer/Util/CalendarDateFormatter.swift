//
//  CalendarDateFormatter.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/01/04.
//

import Foundation

struct CalendarDateFormatter {
    
    private let dateFormatter: DateFormatter = .init()
    private var calendar: Calendar
    
    init(with calendar: Calendar) {
        self.calendar = calendar
    }
    
    // MARK: 인자로 넘어온 Date를 기반으로 해당 월의 모든 날짜를 String 배열로 리턴
    func fetchCurrentMonthDays(from calendarDate: Date) -> [String] {
        let startDayOfWeek: Int = self.calculateStartingDayOfWeek(date: calendarDate)
        let totalDaysOfMonth: Int = startDayOfWeek + self.calculateEndDateOfMonth(date: calendarDate)
        
        var days = [String]()
        
        // 시작 요일 전의 요일들은 숫자 없는 빈 공간으로 놔두기 위해 "" 추가
        for day in 0..<totalDaysOfMonth {
            if day < startDayOfWeek {
                days.append("")
            } else {
                days.append("\(day - startDayOfWeek + 1)")
            }
        }
        
        while (days.count % 7 != 0) {
            days.append("")
        }
        
        return days
    }
    
    func convertToString(from date: Date, with format: String) -> String {
        self.dateFormatter.dateFormat = format
        
        return self.dateFormatter.string(from: date)
    }
}

private extension CalendarDateFormatter {
    
    // MARK: 해당 월의 1일이 시작되는 요일을 계산하여 리턴
    func calculateStartingDayOfWeek(date: Date) -> Int {
        
        // 일요일이 1로 토요일이 7로 반환되는데 배열의 인덱스에 맞추기 위해 -1
        return calendar.component(.weekday, from: date) - 1
    }
    
    // MARK: 해당 달의 날짜가 며칠까지 있는지를 계산하여 리턴
    func calculateEndDateOfMonth(date: Date) -> Int {

        return calendar.range(of: .day, in: .month, for: date)?.count ?? 0
    }
}
