//
//  CalendarManager.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/01/04.
//

import Foundation

final class CalendarService {
    
    private let calendar: Calendar = .current
    private lazy var formatter: CalendarDateFormatter = .init(with: self.calendar)
    
    private var nowDate: Date = .init()
    private(set) var allYears: [String] = []
    private(set) var allYearMonths: [String: [Date]] = [:]
    private(set) var allMonthDays: [Date: [String]] = [:]
    
    private let yearInterval: Int
    
    init(yearInterval: Int) {
        self.yearInterval = yearInterval
        
        self.configureNowDate()
        self.configureAllYears()
    }
    
    func convertYearToString(with date: Date? = nil, format year: String) -> String {
        guard let date else {
            return self.formatter.convertToString(from: nowDate, with: year)
        }
        
        return self.formatter.convertToString(from: date, with: year)
    }
    
    func convertMonthToString(with date: Date? = nil, format month: String) -> String {
        guard let date else {
            return self.formatter.convertToString(from: nowDate, with: month)
        }
        
        return self.formatter.convertToString(from: date, with: month)
    }
}

private extension CalendarService {
    
    func configureNowDate() {
        // .day까지 입력하면 Formatter에서 모든 날짜 가져올 때, 날짜가 밀리는 오류가 발생 (오늘 날짜를 기준으로 1일을 계산)
        let components = self.calendar.dateComponents([.year, .month], from: Date())
        self.nowDate = self.calendar.date(from: components) ?? Date()
    }
    
    // MARK: 올해를 기준으로 이전, 이후의 년도를 구해오는 함수
    func configureAllYears() {
        for plusNum in -(yearInterval)...yearInterval {
            guard let year = self.calendar.date(byAdding: .year, value: plusNum, to: self.nowDate) else {
                NSLog("Can't add year to nowDate")
                
                return
            }
            
            let monthDates: [Date] = self.configureAllMonths(with: year)
            let yearText: String = self.formatter.convertToString(from: year, with: "yyyy년")
            
            self.allYearMonths[yearText] = monthDates
            self.allYears.append(yearText)
        }
    }
    
    // MARK: 해당 년도의 모든 달을 구해오는 함수
    func configureAllMonths(with year: Date) -> [Date] {
        guard let monthNum: Int = Int(self.formatter.convertToString(from: year, with: "MM")) else { return [] }
        
        let firstNum = (1 - monthNum)
        let lastNum = (12 - monthNum)
        
        var yearMonths: [Date] = []
        
        for plusNum in firstNum...lastNum {
            guard let month = self.calendar.date(byAdding: .month, value: plusNum, to: year) else {
                NSLog("Can't add month to yearDate")
                
                return []
            }
            
            self.allMonthDays[month] = self.configureAllDays(with: month)
            yearMonths.append(month)
        }
        
        return yearMonths
    }
    
    // MARK: 해당 월의 모든 날짜를 구해오는 함수
    func configureAllDays(with month: Date) -> [String] {
        
        return self.formatter.fetchCurrentMonthDays(from: month)
    }
}
