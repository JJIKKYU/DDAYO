//
//  Date+Utils.swift
//  Model
//
//  Created by 정진균 on 4/19/25.
//

import Foundation

public extension Date {
    var relativeDescription: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: self, to: now)

        if let minute = components.minute, minute < 1 {
            return "방금 전"
        } else if let minute = components.minute, minute < 60 {
            return "\(minute)분 전"
        } else if let hour = components.hour, hour < 24 {
            return "\(hour)시간 전"
        } else if calendar.isDateInYesterday(self) {
            return "어제"
        } else if let day = components.day {
            if day == 2 {
                return "그저께"
            } else if day <= 13 {
                return "\(day)일 전"
            }
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd"
        return formatter.string(from: self)
    }
}
