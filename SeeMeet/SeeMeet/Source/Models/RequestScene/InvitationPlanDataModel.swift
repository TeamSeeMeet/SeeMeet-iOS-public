//
//  InvitationPlanDataModel.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/01/21.
//

import Foundation

// MARK: - Main
struct InvitationPlanData: Codable {
    let status: Int
    let success: Bool?
    let data: [ScheduleData]?
}

// MARK: - Datum
struct ScheduleData: Codable {
    let id: Int
    let invitationTitle, date, start, end: String
}

extension ScheduleData: Comparable {
    static func < (lhs: ScheduleData, rhs: ScheduleData) -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
        formatter.dateFormat = "hh:mm:ss"
        
        let lh: Date = formatter.date(from: lhs.start) ?? Date()
        let rh: Date = formatter.date(from: rhs.start) ?? Date()
        
        return lh < rh
    }
    
    static func <= (lhs: ScheduleData, rhs: ScheduleData) -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
        formatter.dateFormat = "hh:mm:ss"
        
        let lh: Date = formatter.date(from: lhs.start) ?? Date()
        let rh: Date = formatter.date(from: rhs.start) ?? Date()
        
        return lh <= rh
    }
    
    static func > (lhs: ScheduleData, rhs: ScheduleData) -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
        formatter.dateFormat = "hh:mm:ss"
        
        let lh: Date = formatter.date(from: lhs.start) ?? Date()
        let rh: Date = formatter.date(from: rhs.start) ?? Date()
        
        return lh > rh
    }
    
    static func >= (lhs: ScheduleData, rhs: ScheduleData) -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
        formatter.dateFormat = "hh:mm:ss"
        
        let lh: Date = formatter.date(from: lhs.start) ?? Date()
        let rh: Date = formatter.date(from: rhs.start) ?? Date()
        
        return lh >= rh
    }
    
    
}
