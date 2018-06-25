//
//  DateExtension.swift
//  Mathews
//
//  Created by Mathews on 26/10/17.
//  Copyright © 2017 Mathews. All rights reserved.
//

import Foundation

extension Date {
    
    /// Converts the date to UTC in milliseconds
    ///
    /// - Returns: returns the UTC in milliseconds
    func utcInMilliseconds() -> Double {
        return Double((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    /// Formats the input date to Date in specific timezone
    func convertToLocalTime(fromTimeZone timeZone: TimeZone) -> Date {
        let localOffset = TimeInterval(timeZone.secondsFromGMT(for: self))
        let targetOffset = TimeInterval(TimeZone()!.getTimeZone(isGMT: false).secondsFromGMT(for: self))
        return self.addingTimeInterval(localOffset - targetOffset)
    }
    
    /// returns the start date for the input date
    func startDate() -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone()?.getTimeZone(isGMT: false) ?? TimeZone.current
        return calendar.startOfDay(for: self)
    }
    
    /// returns the end of date for the input date
    func endOfDay() -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone()?.getTimeZone(isGMT: false) ?? TimeZone.current
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return calendar.date(byAdding: components, to: calendar.startOfDay(for: self))
    }
    
    /// Formats Date to string in given format
    ///
    /// - Parameter dateFormat: format specifier for the date string
    /// - Returns: string formatted date
    func string(withDateFormat dateFormat: String, withDeviceLocale deviceLocale: Bool = true) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if deviceLocale {
            dateFormatter.timeZone = TimeZone()?.getTimeZone(isGMT: false)
            dateFormatter.locale = Locale.current
        }
        else {
            dateFormatter.timeZone = TimeZone()?.getTimeZone(isGMT: true)
            dateFormatter.locale = Locale(identifier: "GMT")
        }
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
    /// Computes the day of the week from date
    ///
    /// - Returns: day of the week
    func getDayOfWeek()->Int {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: self)
        return weekDay
    }
    
    func getDayNameForDate(numberOfDay: Int)->String {
        let myCalendar = Calendar(identifier: .gregorian)
        let daysAgo = myCalendar.date(byAdding: .day, value: -numberOfDay, to: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "EE"
        let dayInWeek = dateFormatter.string(from: daysAgo!)
        return dayInWeek.uppercased()
    }
    
    func getTitleDayForDate(dateStr: String) -> String {

        let myCalendar = Calendar(identifier: .gregorian)
        let oneDaysAgo = myCalendar.date(byAdding: .day, value: -1, to: Date())
        
        let todayStr = Date().string(withDateFormat: "MM/dd/yyyy")
        let yesterdayStr = oneDaysAgo?.string(withDateFormat: "MM/dd/yyyy")
        
        if dateStr == todayStr {
            return "Today"
        } else if dateStr == yesterdayStr {
            return "Yesterday"
        }else {
            let dateFrmStr = dateStr.date(dateFormat: "MM/dd/yyyy")
            return dateFrmStr?.string(withDateFormat:DateFormats.dateFormat) ?? ""
        }
        
    }
    
    /// Calculates the difference between current date and given date
    ///
    /// - Parameter component: DateComponent in which difference is to be calculated
    /// - Returns: difference in diven component
    func differenceInDate(component: Calendar.Component) -> Int {
        let dateInput = self
        let components = Calendar.current.dateComponents([.era, .year, .month, .weekOfMonth, .day, .hour, .minute, .second, .nanosecond, .weekday, .weekdayOrdinal, .quarter, .weekOfYear, .yearForWeekOfYear], from: dateInput, to: Date())
        switch component {
        case .era:
            return components.era ?? 0
        case .year:
            return components.year ?? 0
        case .month:
            return components.month ?? 0
        case .weekOfMonth:
            return components.weekOfMonth ?? 0
        case .day:
            return components.day ?? 0
        case .hour:
            return components.hour ?? 0
        case .minute:
            return components.minute ?? 0
        case .second:
            return components.second ?? 0
        case .nanosecond:
            return components.nanosecond ?? 0
        case .weekday:
            return components.weekday ?? 0
        case .weekdayOrdinal:
            return components.weekdayOrdinal ?? 0
        case .quarter:
            return components.quarter ?? 0
        case .weekOfYear:
            return components.weekOfYear ?? 0
        case .yearForWeekOfYear:
            return components.yearForWeekOfYear ?? 0
        default:
            return 0
        }
    }
    
    func substract(milliseconds: UInt64) -> Date {
        let seconds = milliseconds/1000
        return Calendar.current.date(byAdding: .second, value: -(Int(seconds)), to: self)!
    }
}
