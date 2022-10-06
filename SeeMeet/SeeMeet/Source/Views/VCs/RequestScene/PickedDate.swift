//
//  PickedDate.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/01/19.
//

import Foundation

struct PickedDate {
    var startTime: Date = Date()
    var endTime: Date = Date()
   
    func getDateString() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd" // 2020.08.13 16:30
        let str = dateFormatter.string(from: startTime)
        return str
    }
    
    func getDateStringForRequest() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // 2020-08-13 16:30
        let str = dateFormatter.string(from: startTime)
        return str
    }
    
    func getStartTimeStringForRequest() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let str = dateFormatter.string(from: startTime)
        return str
    }
    
    func getEndTimeStringForRequest() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let str = dateFormatter.string(from: endTime)
        return str
    }
    
    func getStartToEndString() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "a hh:mm" // 2020-08-13 16:30
        let start = dateFormatter.string(from: startTime)
        let end = dateFormatter.string(from: endTime)
        
        return start + "~" + end
    }
}

extension PickedDate: Equatable {
    static func == (lhs: PickedDate, rhs: PickedDate) -> Bool {
        return lhs.startTime == rhs.startTime
        && lhs.endTime == rhs.endTime
    }
}
