//
//  Date++.swift
//  SeeMeet_iOS
//
//  Created by 박익범 on 2022/01/05.
//

import Foundation


extension Date {
    
    enum DayOfTheWeek: String, CaseIterable {
        case mon = "월"
        case tue = "화"
        case wed = "수"
        case thu = "목"
        case fri = "금"
        case sat = "토"
        case sun = "일"
    }
    
    static func getCurrentYear() -> String{
        let nowDate = Date() // 현재의 Date (ex: 2020-08-13 09:14:48 +0000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy" // 2020-08-13 16:30
        let str = dateFormatter.string(from: nowDate)
        return str
    }
    
    static func getCurrentMonth() -> String{
        let nowDate = Date() // 현재의 Date (ex: 2020-08-13 09:14:48 +0000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM" // 2020-08-13 16:30
        let str = dateFormatter.string(from: nowDate)
        return str
    }
    
    static func getCurrentDate() -> String{
        let nowDate = Date() // 현재의 Date (ex: 2020-08-13 09:14:48 +0000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd" // 2020-08-13 16:30
        let str = dateFormatter.string(from: nowDate)
        return str
    }
    
    static func getCurrentHour() -> String{
        let nowDate = Date() // 현재의 Date (ex: 2020-08-13 09:14:48 +0000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh" // 2020-08-13 16:30
        let str = dateFormatter.string(from: nowDate)
        return str
    }
    
    static func getCurrentMinute() -> String{
        let nowDate = Date() // 현재의 Date (ex: 2020-08-13 09:14:48 +0000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm" // 2020-08-13 16:30
        let str = dateFormatter.string(from: nowDate)
        return str
    }
    
    static func getCurrentKoreanWeekDay() -> String {
        getKoreanWeekDay(from: Date())
    }
    
    static func getKoreanWeekDay(from date: Date) -> String {
        let currentDay = Calendar.current.component(.weekday, from: date)
        
        switch currentDay {
        case 1:
            return "일"
        case 2:
            return "월"
        case 3:
            return "화"
        case 4:
            return "수"
        case 5:
            return "목"
        case 6:
            return "금"
        case 7:
            return "토"
        default:
            return "일"
        }
    }
    
    public var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    public var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    public var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    public var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    public var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    public var weekday: Int{
        return Calendar.current.component(.weekday, from: self) - 1
    }
    
    public var isLeapMonth: Bool{
        if year % 400 == 0 || (year % 4 == 0 && year % 100 != 0){
            return true
        }
        else{
            return false
        }
    }
    
    public var numberOfMonth: Int{
        let numberList = [0,31,28,31,30,31,30,31,31,30,31,30,31]
        if isLeapMonth && month == 2{
            return 29
        }
        else{
            return numberList[month]
        }
    }
    
    public var firstWeekday: Int{
        var dateComponent = DateComponents()
        dateComponent.year = Calendar.current.component(.year, from: self)
        dateComponent.month = Calendar.current.component(.month, from: self)
        dateComponent.day = 1
        dateComponent.weekday = Calendar.current.component(.weekday,from: Calendar.current.date(from: dateComponent)!)
        /// 리턴값 : 일 - 토 -> 0 - 6
        return dateComponent.weekday! - 1
    }
    
    func nextDate() -> Date {
        let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: self)
        return nextDate ?? Date()
    }
    
    func nextDate(value: Int) -> Date{
        let nextDate = Calendar.current.date(byAdding: .day, value: value, to: self)
        return nextDate ?? Date()
    }
    
    func previousDate() -> Date {
        let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: self)
        return previousDate ?? Date()
    }
    
    func previousDate(value: Int) -> Date {
        let previousDate = Calendar.current.date(byAdding: .day, value: -value, to: self)
        return previousDate ?? Date()
    }
    func nextWeekDate() -> Date {
        let nextDate = Calendar.current.date(byAdding: .day, value: 7, to: self)
        return nextDate ?? Date()
    }
    func prevWeekDate() -> Date {
        let nextDate = Calendar.current.date(byAdding: .day, value: -7, to: self)
        return nextDate ?? Date()
    }
    
}

