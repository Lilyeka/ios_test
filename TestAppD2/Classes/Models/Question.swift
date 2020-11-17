//
//  Question.swift
//  TestAppD1
//
//  Created by  on 24/01/2019.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

struct Question: Decodable {
    let items: [Item]?
}

struct Item: Decodable {
    let owner: Owner?
    let answer_count: Int?
    let question_id: Int?
    let last_activity_date: Int?
    let title: String?
    var smartDateFormat: String? {
        if let last_activity_date = self.last_activity_date,
           let timeInterval = TimeInterval(exactly:last_activity_date) {
                return Item.timeAgoString(from: Date.init(timeIntervalSince1970:timeInterval))
        }
        return nil
    }

    static func timeAgoString(from date: Date?) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        let now = Date()
        let calendar = Calendar.current
        var components: DateComponents
        if let aDate = date {
            components = calendar.dateComponents([.year, .month, .weekOfMonth, .day, .hour, .minute, .second], from: aDate, to: now)
            if let year = components.year, year > 0 {
                formatter.allowedUnits = NSCalendar.Unit.year
            } else if let month = components.month, month > 0 {
                formatter.allowedUnits = .month
            } else if let weekOfMonth = components.weekOfMonth, weekOfMonth > 0 {
                formatter.allowedUnits = .weekOfMonth
            } else if let day = components.day, day > 0 {
                formatter.allowedUnits = .day
            } else if let hour = components.hour, hour > 0 {
                formatter.allowedUnits = .hour
            } else if let minute = components.minute, minute > 0 {
                formatter.allowedUnits = .minute
            } else {
                formatter.allowedUnits = .second
            }
            return "  \(formatter.string(from: components) ?? "") ago"
        }
        return ""
    }
}

struct Owner: Decodable {
    let display_name: String?
}
