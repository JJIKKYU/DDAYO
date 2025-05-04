//
//  Date+Utils.swift
//  Model
//
//  Created by 정진균 on 4/19/25.
//

import Foundation

public extension Date {
    var relativeDescription: String {
        let secondsAgo = -self.timeIntervalSinceNow
        let minute = Int(secondsAgo / 60)
        let hour = Int(secondsAgo / 3600)
        let day = Int(secondsAgo / 86400)

        if secondsAgo < 60 {
            return "방금 전"
        } else if minute < 60 {
            return "\(minute)분 전"
        } else if hour < 24 {
            return "\(hour)시간 전"
        } else {
            let calendar = Calendar.current
            if calendar.isDateInYesterday(self) {
                return "어제"
            } else if day == 2 {
                return "그저께"
            } else if day <= 13 {
                return "\(day)일 전"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "yy.MM.dd"
                return formatter.string(from: self)
            }
        }
    }
}
